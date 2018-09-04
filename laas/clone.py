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
        r = requests.get(f'https://{url}/{prj}')
        r.raise_for_status()
        if 'You need to sign in or sign up before continuing.' in r.content.decode():
            raise FileNotFoundError(f'https://{url}/{prj} does not exist')

for org, prj in ORG_PRJ:
    print('{:=^80}'.format(f' {org} / {prj} '))
    check_call(['git', 'clone', '--recursive', f'git@{GL}:{ML}/{prj}.git'], cwd=org)
    cwd = f'{org}/{prj}'

    def call(cmd):
        check_call(cmd.split(), cwd=cwd)

    devel_from_main = False
    try:
        call('git checkout devel')
    except CalledProcessError:
        if requests.get(f'https://{GH}/{org}/{prj}/tree/devel').status_code == 200:
            devel_from_main = True
        else:
            call('git checkout -b devel')
            call('git push origin devel')
            call('git branch --set-upstream-to=origin/devel devel')
    call(f'git remote add main git@{GH}:{org}/{prj}.git')
    call('git fetch main')
    if devel_from_main:
        call('git checkout devel')
    call(f'git remote add maingl git@{GL}:{org}/{prj}.git')
    call('git fetch maingl')
    call(f'git remote add github git@{GH}:{MH}/{prj}.git')
    call('git fetch github')
    call('git checkout master')
