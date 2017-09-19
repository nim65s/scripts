#!/usr/bin/env python3

# sorted version of passmenu from password-store
# Can be used like this with dmenu, or if you have rofi:
# ./spassmenu.py -matching fuzzy -no-lazy-grab

# TODO: use XDG_CACHE_DIR & PASSWORD_STORE_DIR & PASSWORD_STORE_CLIP_TIME

import shelve
import sys
from os.path import expanduser
from pathlib import Path
from subprocess import PIPE, run

SHELF = expanduser('~/.cache/spassmenu')
PASSWORD_STORE_DIR = Path(expanduser('~/.password-store'))


with shelve.open(SHELF) as shelf:
    pwds = shelf['pwds'] if 'pwds' in shelf else []

for filename in PASSWORD_STORE_DIR.glob('**/*.gpg'):
    pwd = str(filename.relative_to(PASSWORD_STORE_DIR))[:-4]
    if pwd not in pwds:
        pwds.append(pwd)

out = run(['dmenu'] + sys.argv[1:], input='\n'.join(pwds), stdout=PIPE, universal_newlines=True).stdout.strip()

if out:
    run(['pass', '-c', out])
    run(['notify-send', '-t', '45000', out])

    while out in pwds:
        pwds.remove(out)
    pwds = [out] + pwds

    with shelve.open(SHELF) as shelf:
        shelf['pwds'] = pwds
