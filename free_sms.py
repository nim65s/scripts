#!/usr/bin/env python3

import sys
from os.path import expanduser

import requests


def sendmsg(user_id, key, msg):
    params = {'user': user_id, 'pass': key, 'msg': msg}
    url = 'https://smsapi.free-mobile.fr/sendmsg'
    requests.get(url, params=params, verify=False).raise_for_status()


if __name__ == '__main__':
    with open(expanduser('~/.free'), 'r') as f:
        user, key = f.read().split()

    sendmsg(user, key, ' '.join(sys.argv[1:]))
