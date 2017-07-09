#!/usr/bin/env python3

from os.path import expanduser

import grequests
import requests
from tabulate import tabulate

IGNORE = ['nim65s/cdl-blog', 'nim65s/rhetoriquerobotique']

with open(expanduser('~/.githubtoken')) as f:
    TOKEN = f.read().strip()
HEADERS = {'Authorization': f'token {TOKEN}'}

PyPI = 'https://pypi.python.org/pypi/%s/json'
REQUIREMENTS = 'https://raw.githubusercontent.com/%s/master/requirements.txt'
REPOS = 'https://api.github.com/user/repos'

repos = {}
all_packages = set()
all_repos = []


def show(package, repo, pypi):
    if package in repos[repo]:
        if repos[repo][package] == pypi:
            return "✔"
        else:
            return repos[repo][package]
    else:
        return ""


for page in range(1000):
    user_repos = requests.get(REPOS, {'per_page': 100, 'page': page}, headers=HEADERS).json()
    if not user_repos:
        break
    all_repos += [repo['full_name'] for repo in user_repos if repo['full_name'] not in IGNORE]

for r in grequests.imap((grequests.get(REQUIREMENTS % repo, headers=HEADERS) for repo in all_repos)):
    if r.status_code == 200:
        full_name = '/'.join(r.url.split('/')[3:5])
        try:
            packages = [line.split()[0].split('==') for line in r.content.decode().split('\n')
                        if line and not line.startswith('#') and not line.startswith('-e')]
            repos[full_name] = {package: version for package, version in packages}
            for package in packages:
                all_packages.add(package[0])
        except Exception as e:
            print(f'Error on {full_name}: {e}')

all_packages = sorted(all_packages)
all_repos = sorted(repos.keys())

table = [["", ""] + [repo.split('/')[0] for repo in all_repos]]
table += [["Package", "PyPI"] + [repo.split('/')[1] for repo in all_repos]]
for package in all_packages:
    pypi = requests.get(PyPI % package).json()['info']['version']
    table += [[package, pypi] + [show(package, repo, pypi) for repo in all_repos]]

print(tabulate(table))
