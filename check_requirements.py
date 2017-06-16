#!/usr/bin/env python3

import requests

USERS = ['nim65s']
repos = {}

for user in USERS:
    user_repos = requests.get(f'https://api.github.com/users/{user}/repos').json()
    for repo in user_repos:
        full_name = repo['full_name']
        r = requests.get(f'https://raw.githubusercontent.com/{full_name}/master/requirements.txt')
        if r.status_code == 200:
            repos[full_name] = r.content.decode().split('\n')


print(repos)
