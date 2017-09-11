#!/usr/bin/env python3

import sys
from os.path import expanduser

import grequests
import requests
from tabulate import tabulate
from tqdm import tqdm

IGNORE = ['nim65s/cdl-blog', 'nim65s/rhetoriquerobotique']

with open(expanduser('~/.githubtoken')) as f:
    TOKEN = f.read().strip()
HEADERS = {'Authorization': f'token {TOKEN}'}

PyPI = 'https://pypi.python.org/pypi/%s/json'
REQUIREMENTS = 'https://raw.githubusercontent.com/%s/master/requirements.txt'
REPOS = 'https://api.github.com/user/repos'

FIX_NAMES = [
    ('asgi_redis', 'asgi-redis'),
    ('service_identity', 'service-identity'),
]

repos = {}
pypi = {}
all_packages = set()
all_repos = []


def show(package, repo, pypi):
    " Show the version of {package} in {repo} wrt {pypi} "
    if package in repos[repo]:
        if repos[repo][package] == pypi:
            return "✔"
        else:
            return repos[repo][package]
    else:
        return ""


def dl(url_template, url_arguments, desc=''):
    " Download in parallel {url_template} for each {url_arguments}, with a progress bar describing {desc}"
    all_requests = (grequests.get(url_template % arg, headers=HEADERS) for arg in url_arguments)
    yield from tqdm(grequests.imap(all_requests), desc=desc, total=len(url_arguments))


if __name__ == '__main__':
    # Get the list of {all_repos} to consider.
    if len(sys.argv) > 1:
        all_repos = sys.argv[1:]
    else:
        for page in range(1000):
            user_repos = requests.get(REPOS, {'per_page': 100, 'page': page}, headers=HEADERS).json()
            if not user_repos:
                break
            all_repos += [repo['full_name'] for repo in user_repos if repo['full_name'] not in IGNORE]

    # Parse the requirements.txt file from each repo from {all_repos}
    for r in dl(REQUIREMENTS, all_repos, 'repositories'):
        if r.status_code == 200:
            full_name = '/'.join(r.url.split('/')[3:5])
            try:
                packages = [line.split()[0].split('==') for line in r.content.decode().split('\n')
                            if line and not line.startswith('#') and not line.startswith('-e')]
                repos[full_name] = {package.lower(): version for package, version in packages}
                for package in packages:
                    all_packages.add(package[0].lower().split('[')[0])
            except Exception as e:
                print(f'Error on {full_name}: {e}')

    all_packages = sorted(all_packages)
    all_repos = sorted(repos.keys())

    # Get the Pypi version of {all_packages}
    for r in dl(PyPI, all_packages, 'packages'):
        info = r.json()['info']
        pypi[info['name'].lower()] = info['version']

    for old, new in FIX_NAMES:
        pypi[new] = pypi[old]

    # Print a everything in a table
    table = [["", ""] + [repo.split('/')[0] for repo in all_repos]]
    table += [["Package", "PyPI"] + [repo.split('/')[1] for repo in all_repos]]
    for package in all_packages:
        table += [[package, pypi[package]] + [show(package, repo, pypi[package]) for repo in all_repos]]

    print(tabulate(table))
