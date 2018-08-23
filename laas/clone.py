#!/usr/bin/env python3.6

from subprocess import CalledProcessError, check_call

import requests

GL = 'gepgitlab.laas.fr'
GH = 'github.com'
ML = 'gsaurel'
MH = 'nim65s'

API = 'http://rainboard.laas.fr/api/%s/'
ORG = {i['id']: i['slug'] for i in requests.get(API % 'namespace').json()}
PRJ = requests.get(API % 'project', {'from_gepetto': True}).json()

IGNORE = ['sot-hpp', 'stack-of-tasksgithubcom']

ORG_PRJ = sorted((ORG[i['main_namespace']], i['slug']) for i in PRJ if i['slug'] not in IGNORE)

for org, prj in ORG_PRJ:
    for url in [f'{GL}/{ML}', f'{GH}/{MH}', f'{GL}/{org}', f'{GH}/{org}']:
        requests.get(f'https://{url}/{prj}').raise_for_status()

for org, prj in ORG_PRJ:
    print('{:=^80}'.format(f' {org} / {prj} '))
    check_call(['git', 'clone', '--recursive', f'git@{GL}:{ML}/{prj}.git'], cwd=org)
    cwd = f'{org}/{prj}'
    devel_from_main = False
    try:
        check_call(['git', 'checkout', 'devel'], cwd=cwd)
    except CalledProcessError:
        if requests.get(f'https://{GH}/{org}/{prj}/tree/devel').status_code == 200:
            devel_from_main = True
        else:
            check_call(['git', 'checkout', '-b', 'devel'], cwd=cwd)
    check_call(['git', 'remote', 'add', 'main', f'git@{GH}:{org}/{prj}.git'], cwd=cwd)
    check_call(['git', 'fetch', 'main'], cwd=cwd)
    if devel_from_main:
        check_call(['git', 'checkout', 'devel'], cwd=cwd)
    check_call(['git', 'remote', 'add', 'maingl', f'git@{GL}:{org}/{prj}.git'], cwd=cwd)
    check_call(['git', 'fetch', 'maingl'], cwd=cwd)
    check_call(['git', 'remote', 'add', 'github', f'git@{GH}:{MH}/{prj}.git'], cwd=cwd)
    check_call(['git', 'fetch', 'github'], cwd=cwd)
    check_call(['git', 'checkout', 'master'], cwd=cwd)
