#!/usr/bin/env python3

from concurrent.futures import ThreadPoolExecutor, as_completed
from os.path import expanduser, isdir, isfile
from subprocess import PIPE, STDOUT, Popen

CONFIG = expanduser('~/.gitrepos')

REMOVE = [
    '',
    'Déjà à jour.',
    'rien à valider, la copie de travail est propre',
    'Premièrement, rembobinons head pour rejouer votre travail par-dessus...',
    'Sur la branche master',
    "Votre branche est à jour avec 'origin/master'.",
    'La branche courante master est à jour.',
    'master mise à jour en avance rapide sur refs/remotes/origin/master.',
    "Déjà sur 'master'",
]


def title(string):
    "Bold Green with spaces"
    return f"\033[1;32m {string} \033[0m"


def run(cmds, repo):
    return Popen(cmds, stderr=STDOUT, stdout=PIPE, cwd=repo, universal_newlines=True).stdout.read().split('\n')


def gitup(repo):
    if repo.startswith('-'):
        return
    if not isdir(repo):
        raise ValueError(f'«{repo}» is not a directory')
    ret = [title(repo)]
    for cmds in [['git', 'fetch'], ['git', 'rebase']]:
        ret += run(cmds, repo)
    if isfile('.gitmodules'):
        for cmds in [['git', 'submodule', 'update', '--recursive', '--remote', '--rebase', '--init'],
                     ['git', 'submodule', 'foreach', '-q',
                      'git checkout $(git config -f $toplevel/.gitmodules submodule.$name.branch || echo master)']]:
            ret += run(cmds, repo)
    return ret + run(['git', 'status'], repo)


def clean(output):
    for rm in REMOVE:
        while rm in output:
            output.remove(rm)
    if len(output) > 1:
        print('\n'.join(output))


if __name__ == '__main__':
    with open(CONFIG) as f:
        REPOS = map(str.strip, f.readlines())

    with ThreadPoolExecutor() as executor:
        futures = {executor.submit(gitup, repo): repo for repo in REPOS}
        for future in as_completed(futures):
            repo = futures[future]
            clean(future.result())
