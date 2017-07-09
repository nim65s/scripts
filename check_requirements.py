#!/usr/bin/env python3

import requests
from tabulate import tabulate

USERS = ['nim65s']
IGNORE = ['nim65s/cdl-blog']
PyPI = 'http://pypi.python.org/pypi/%s/json'

repos = {}
all_packages = set()

for user in USERS:
    user_repos = requests.get(f'https://api.github.com/users/{user}/repos').json()
    for repo in user_repos:
        full_name = repo['full_name']
        if full_name in IGNORE:
            continue
        r = requests.get(f'https://raw.githubusercontent.com/{full_name}/master/requirements.txt')
        if r.status_code == 200:
            packages = [line.split()[0].split('==') for line in r.content.decode().split('\n')
                        if line and not line.startswith('#') and not line.startswith('-e')]
            repos[full_name] = {package: version for package, version in packages}
            for package in packages:
                all_packages.add(package[0])

all_packages = sorted(all_packages)
all_repos = sorted(repos.keys())


def show(package, repo, pypi):
    if package in repos[repo]:
        if repos[repo][package] == pypi:
            return "✔"
        else:
            repos[repo][package]
    else:
        return ""


table = [["", ""] + [repo.split('/')[0] for repo in all_repos]]
table += [["Package", "PyPI"] + [repo.split('/')[1] for repo in all_repos]]
for package in all_packages:
    pypi = requests.get(PyPI % package).json()['info']['version']
    table += [[package, pypi] + [show(package, repo, pypi) for repo in all_repos]]

print(tabulate(table))
