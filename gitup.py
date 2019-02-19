#!/usr/bin/env python3

from concurrent.futures import ThreadPoolExecutor, as_completed
from os.path import expanduser, isdir, isfile, join
from subprocess import PIPE, STDOUT, Popen

CONFIG = expanduser('~/.gitrepos')

REMOVE = [
    '',
    'Déjà à jour.',
    'rien à valider, la copie de travail est propre',
    'nothing to commit, working tree clean',
    'Premièrement, rembobinons head pour rejouer votre travail par-dessus...',
    'First, rewinding head to replay your work on top of it...',
    "Rembobinage préalable de head pour pouvoir rejouer votre travail par-dessus...",
    'Sur la branche master',
    'On branch master',
    "Votre branche est à jour avec 'origin/master'.",
    "Your branch is up-to-date with 'origin/master'.",
    'La branche courante master est à jour.',
    'Current branch master is up to date.',
    'master mise à jour en avance rapide sur refs/remotes/origin/master.',
    'Avance rapide de master sur refs/remotes/origin/master.',
    'Fast-forwarded master to refs/remotes/origin/master.',
    "Déjà sur 'master'",
    'Already up-to-date.',
    'warning: agent returned different signature type ssh-rsa (expected rsa-sha2-512)',
    'sign_and_send_pubkey: signing failed: agent refused operation',
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
    if isfile(join(repo, '.gitmodules')):
        for cmds in [['git', 'submodule', 'update', '--remote', '--rebase', '--init'],
                     ['git', 'submodule', 'foreach', '-q', 'git', 'pull', '--rebase']]:
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
        REPOS = [line.strip() for line in f.readlines() if line.startswith('/')]

    with ThreadPoolExecutor() as executor:
        futures = {executor.submit(gitup, repo): repo for repo in REPOS}
        for future in as_completed(futures):
            clean(future.result())
