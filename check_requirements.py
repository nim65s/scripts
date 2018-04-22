#!/usr/bin/env python3

import re
import sys
from os.path import expanduser

import grequests
import requests
from tabulate import tabulate
from tqdm import tqdm

IGNORE = ['nim65s/cdl-blog']

with open(expanduser('~/.githubtoken')) as f:
    TOKEN = f.read().strip()
HEADERS = {'Authorization': f'token {TOKEN}'}

PyPI = 'https://pypi.python.org/pypi/%s/json'
REQUIREMENTS = 'https://raw.githubusercontent.com/%s/master/requirements.txt'
REPOS = 'https://api.github.com/user/repos'

repos = {}


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


def package_name(name):
    return re.sub('[^A-Za-z0-9.]+', '-', name.split('[')[0].lower())


def get_all_repos():
    all_repos = []
    for page in range(1000):
        user_repos = requests.get(REPOS, {'per_page': 100, 'page': page}, headers=HEADERS).json()
        if not user_repos:
            return all_repos
        all_repos += [repo['full_name'] for repo in user_repos
                      if not repo['archived'] and repo['full_name'] not in IGNORE]


def get_all():
    # Get the list of {all_repos} to consider.
    all_packages = set()
    all_repos = sys.argv[1:] if len(sys.argv) > 1 else get_all_repos()

    # Parse the requirements.txt file from each repo from {all_repos}
    for r in dl(REQUIREMENTS, all_repos, 'repositories'):
        if r.status_code == 200:
            full_name = '/'.join(r.url.split('/')[3:5])
            try:
                packages = [line.split()[0].split('==') for line in r.content.decode().split('\n')
                            if line and not line.startswith('#') and '#egg=' not in line]
                repos[full_name] = {package: version for package, version in packages}
                for package in packages:
                    all_packages.add(package[0].split('[')[0])
            except Exception as e:
                print(f'Error on {full_name}: {e}')

    return sorted(all_packages), sorted(repos.keys())


def get_pypi(all_packages):
    # Get the Pypi version of {all_packages}
    pypi = {}
    for r in dl(PyPI, all_packages, 'packages'):
        pypi[package_name(r.url.split('/')[4])] = r.json()['info']['version']
    return pypi


def print_tables(all_packages, all_repos, pypi):
    # separate up-to-date repos and to-update repos, and ther packages
    up_to_date_packages = set()
    to_update_packages = set()
    up_to_date_repos = set()
    to_update_repos = set()

    for repo in all_repos:
        if all(version == pypi[package_name(package)] for package, version in repos[repo].items()):
            up_to_date_repos.add(repo)
            up_to_date_packages |= set(package_name(p) for p in repos[repo].keys())
        else:
            to_update_repos.add(repo)
            to_update_packages |= set(package_name(p) for p in repos[repo].keys())

    up_to_date_packages = sorted(up_to_date_packages)
    to_update_packages = sorted(to_update_packages)
    up_to_date_repos = sorted(up_to_date_repos)
    to_update_repos = sorted(to_update_repos)

    # Print a everything in tables
    to_update_table = [["", ""] + [repo.split('/')[0] for repo in to_update_repos]]
    to_update_table += [["Package", "PyPI"] + [repo.split('/')[1][:10] for repo in to_update_repos]]
    for package in to_update_packages:
        to_update_table += [[package, pypi[package]] +
                            [show(package, repo, pypi[package]) for repo in to_update_repos]]

    up_to_date_table = [["", ""] + [repo.split('/')[0] for repo in up_to_date_repos]]
    up_to_date_table += [["Package", "PyPI"] + [repo.split('/')[1][:10] for repo in up_to_date_repos]]
    for package in up_to_date_packages:
        up_to_date_table += [[package, pypi[package]] +
                             [show(package, repo, pypi[package]) for repo in up_to_date_repos]]

    print(tabulate(up_to_date_table))
    print(tabulate(to_update_table))


if __name__ == '__main__':
    all_packages, all_repos = get_all()
    pypi = get_pypi(all_packages)
    print_tables(all_packages, all_repos, pypi)
