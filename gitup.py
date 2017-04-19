#!/usr/bin/env python3

from concurrent.futures import ThreadPoolExecutor, as_completed
from os import chdir
from os.path import expanduser, isdir, isfile
from subprocess import PIPE, STDOUT, run

CONFIG = expanduser('~/.gitrepos')

REMOVE = [
    '',
    'Déjà à jour.',
    'Sur la branche master',
    'rien à valider, la copie de travail est propre',
    "Votre branche est à jour avec 'origin/master'.",
    'La branche courante master est à jour.',
    'Premièrement, rembobinons head pour rejouer votre travail par-dessus...',
    'master mise à jour en avance rapide sur refs/remotes/origin/master.',
]


def title(string):
    "Bold Green with spaces"
    return f"\033[1;32m {string} \033[0m"


def gitup(repo):
    if repo.startswith('-'):
        return
    if not isdir(repo):
        raise ValueError(f'«{repo}» is not a directory')
    chdir(repo)
    ret = [title(repo)]
    for cmds in [['git', 'fetch'], ['git', 'rebase']]:
        ret += run(cmds, stderr=STDOUT, stdout=PIPE).stdout.decode().split('\n')
    if isfile('.gitmodules'):
        for cmds in [['git', 'submodule', 'update', '--recursive', '--remote', '--rebase', '--init'],
                     ['git', 'submodule', 'foreach', '-q',
                      'git checkout $(git config -f $toplevel/.gitmodules submodule.$name.branch || echo master)']]:
            ret += run(cmds, stderr=STDOUT, stdout=PIPE).stdout.decode().split('\n')
    return ret + run(['git', 'status'], stderr=STDOUT, stdout=PIPE).stdout.decode().split('\n')


def clean(output):
    for rm in REMOVE:
        while rm in output:
            output.remove(rm)
    if len(output) > 2:
        print('\n'.join(output))


if __name__ == '__main__':
    with open(CONFIG) as f:
        REPOS = map(str.strip, f.readlines())

    with ThreadPoolExecutor() as executor:
        futures = {executor.submit(gitup, repo): repo for repo in REPOS}
        for future in as_completed(futures):
            repo = futures[future]
            clean(future.result())
