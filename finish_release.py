#!/usr/bin/env python3
"""
Finish a release, after it has been pushed to robotpkg:
    - find the last release tag
    - check devel & stable status
    - update stable with the tag, then devel with stable
    - push the tag, devel & stable
    - get the distfiles in /tmp
    - show the url for creating a release on github
    - show the version message from robotpkg
"""

from argparse import ArgumentParser
from os import chdir, environ, getcwd
from os.path import expanduser
from pathlib import Path
from re import match
from shutil import copy
from subprocess import check_call, check_output

import httpx

STABLE = 'stable' if 'stable' in check_output('git branch -a'.split()).decode() else 'master'
BRANCHES = ['devel', STABLE]
RPKG = Path('/usr/local/openrobots/distfiles')
CWD = Path(getcwd())
if CWD.name == 'build':
    chdir('..')
    CWD = Path(getcwd())

parser = ArgumentParser()
parser.add_argument('namespace', nargs='?', default=CWD.parent.name)
parser.add_argument('project', nargs='?', default=CWD.name)
parser.add_argument('--robotpkg', type=Path, default=Path(expanduser('~/local/robotpkg/robotpkg')))
parser.add_argument('--wip', action='store_true')
parser.add_argument('--private', action='store_true')
parser.add_argument('--suffix', default='')
args = parser.parse_args()

if args.suffix:
    args.suffix = f'-{args.suffix}'

FROM_LAAS = True
try:
    chdir(RPKG)
    chdir(CWD)
except FileNotFoundError:
    FROM_LAAS = False

REMOTES = {
    'main': f'git@gitlab.laas.fr:{args.namespace}/{args.project}.git',
    'origin': f'git@gitlab.laas.fr:gsaurel/{args.project}.git',
} if args.private else {
    'github': f'git@github.com:nim65s/{args.project}.git',
    'main': f'git@github.com:{args.namespace}/{args.project}.git',
    'maingl': f'git@gitlab.laas.fr:{args.namespace}/{args.project}.git',
    'origin': f'git@gitlab.laas.fr:gsaurel/{args.project}.git',
}


def check_remotes():
    "Check that the project complies to the template"
    out = check_output('git remote -v'.split()).decode()
    for remote, url in REMOTES.items():
        if f'{remote}\t{url}' not in out:
            raise EnvironmentError(f'The current working directory does not follow the template: {remote} {url}')


def get_release():
    "get the tag name of the latest release"
    tags = check_output('git tag -l'.split()).decode().splitlines()
    major, minor, patch = sorted([int(v) for v in tag[1:].split('.')] for tag in tags
                                 if match(r'^v\d+\.\d+\.\d+$', tag))[-1]
    return f'v{major}.{minor}.{patch}'


def ndiff(a, b):
    "get the number of commits from a to b"
    return len(check_output(f'git rev-list {a}..{b}'.split()).decode().strip().splitlines())


def update_branches():
    "pull changes from the main remotes in the local branches"
    for branch in BRANCHES:
        for remote in REMOTES.keys():
            if ndiff(branch, f'{remote}/{branch}') > 0:
                if ndiff(f'{remote}/{branch}', branch) > 0:
                    raise RuntimeError(f'{branch} and {remote}/{branch} have diverged')
                else:
                    check_call(f'git checkout {branch}'.split())
                    check_call(f'git pull {remote} {branch}'.split())


def merge_release(release):
    "merge the latest release into stable, and then stable into devel"
    check_call(f'git checkout {STABLE}'.split())
    check_call(f'git merge {release}'.split())
    check_call(f'git checkout devel'.split())
    check_call(f'git merge {STABLE}'.split())


def download(version):
    "download the released tarball and its gpg signature from robotpkg"
    robotpkg_project = args.project.replace('_', '-')

    def dl(project):
        for ext in ['tar.gz', 'tar.gz.sig']:
            filename = f'{project}{args.suffix}-{version}.{ext}'
            if FROM_LAAS:
                copy(RPKG / robotpkg_project / filename, '/tmp')
            else:
                with (Path('/tmp') / filename).open('wb') as f:
                    url = f'http://www.openrobots.org/distfiles/{robotpkg_project}/{filename}'
                    with httpx.stream("GET", url) as r:
                        r.raise_for_status()
                        for chunk in r.iter_bytes():
                            f.write(chunk)
        full_filename = f'/tmp/{project}{args.suffix}-{version}.tar.gz'
        check_call(f'gpg --verify {full_filename}.sig'.split())
        return full_filename

    try:
        return dl(args.project)
    except httpx.HTTPError:
        return dl(args.project.replace('-', '_'))


def get_message(release):
    "get the release message from robotpkg"
    robotpkg_project = args.project.replace('_', '-').replace('dynamic-graph-python', 'py-dynamic-graph')
    cwd = args.robotpkg / 'wip' if args.wip else args.robotpkg
    for suffix in [args.suffix, '-v3']:
        contents = [f'{robotpkg_project}{suffix}]', release]
        print(f'looking for "{contents}" in', 'robotpkg-wip' if args.wip else 'robotpkg')
        for line in check_output('git log --oneline'.split(), cwd=cwd).decode().splitlines():
            if all(content in line for content in contents):
                commit = line.split()[0].replace('\x1b[33m', '').replace('\x1b[m', '')
                m = check_output(f'git show -s {commit}'.split(), cwd=cwd).decode()
                return '\n'.join([line.strip() for line in m.split('\n')[6:]])


if __name__ == '__main__':
    check_remotes()
    release = get_release()
    print(f'=== RELEASING {args.namespace} / {args.project }, {release} ===')
    print(check_output('git status'.split()).decode())
    check_call('git fetch --all --prune'.split())

    print('Updating local branches…')
    update_branches()

    print(check_output('git status'.split()).decode())

    print('Merging release…')
    merge_release(release)

    # input(f'going to push devel, stable and {release}, press Enter to continue, ^C to abort')
    print('Pushing…')
    for remote in REMOTES.keys():
        check_call(f'git push {remote} devel {release} {STABLE}'.split())

    print('Downloading files…')
    filename = download(release[1:])
    print('Getting message…')
    message = get_message(release)
    print('Getting github token')
    github_token = check_output(['pass', 'web/github/ghcli-token']).decode().strip()
    print('Publishing release draft…')
    check_call([
        'gh', 'release', 'create', '-d', '-n', message, '-t', f'Release {release}', '-R',
        f'{args.namespace}/{args.project}', release, filename, f'{filename}.sig'
    ],
               env={
                   'GITHUB_TOKEN': github_token,
                   **environ
               })
