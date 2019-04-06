#!/usr/bin/env python3

import re
import sys
from json import loads
from subprocess import check_output

import grequests
import requests
from tabulate import tabulate
from tqdm import tqdm

IGNORE = ['nim65s/cdl-blog', 'nim65s/PonyConf', 'nim65s/dashboard']
TOKEN_PASS_PATH = 'web/github_token'

TOKEN = check_output(['pass', TOKEN_PASS_PATH]).decode().split()[0]
HEADERS = {'Authorization': f'token {TOKEN}'}

PyPI = 'https://pypi.python.org/pypi/%s/json'
PIPFILE_LOCK = 'https://raw.githubusercontent.com/%s/master/Pipfile.lock'
REPOS = 'https://api.github.com/user/repos'
PINNED = {'olefile': '0.43', 'pillow': '5.4.1'}

repos = {}


def show(package, repo, pypi):
    " Show the version of {package} in {repo} wrt {pypi} "
    if package in repos[repo]:
        if repos[repo][package] == pypi:
            return "✔"
        elif package in PINNED and repos[repo][package] == PINNED[package]:
            return "P"
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
        all_repos += [
            repo['full_name'] for repo in user_repos if not repo['archived'] and repo['full_name'] not in IGNORE
        ]


def get_all():
    # Get the list of {all_repos} to consider.
    all_packages = set()
    all_repos = sys.argv[1:] if len(sys.argv) > 1 else get_all_repos()

    # Parse the Pipfile.lock file from each repo from {all_repos}
    for r in dl(PIPFILE_LOCK, all_repos, 'Pipfile.lock'):
        if r.status_code == 200:
            full_name = '/'.join(r.url.split('/')[3:5])
            try:
                content = loads(r.content)['default']
                repos[full_name] = {package: data['version'].replace('==', '') for package, data in content.items()}
                for package in content.keys():
                    all_packages.add(package.split('[')[0])
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
        if all(version == pypi[package_name(package)] or package in PINNED and version == PINNED[package]
               for package, version in repos[repo].items()):
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
        to_update_table += [
            [package, pypi[package]] + [show(package, repo, pypi[package]) for repo in to_update_repos]
        ]

    up_to_date_table = [["", ""] + [repo.split('/')[0] for repo in up_to_date_repos]]
    up_to_date_table += [["Package", "PyPI"] + [repo.split('/')[1][:10] for repo in up_to_date_repos]]
    for package in up_to_date_packages:
        up_to_date_table += [
            [package, pypi[package]] + [show(package, repo, pypi[package]) for repo in up_to_date_repos]
        ]

    print(tabulate(up_to_date_table))
    print(tabulate(to_update_table))


if __name__ == '__main__':
    all_packages, all_repos = get_all()
    pypi = get_pypi(all_packages)
    print_tables(all_packages, all_repos, pypi)
