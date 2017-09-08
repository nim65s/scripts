#!/usr/bin/env python3

import shelve
from os.path import expanduser
from subprocess import PIPE, run

SHELF = expanduser('~/.cache/demunim')

with shelve.open(SHELF) as shelf:
    cmds = shelf['cmds'] if 'cmds' in shelf else False

if not cmds:
    from os import environ
    from pathlib import Path
    from stat import S_IEXEC, S_IXGRP, S_IXOTH

    def is_cmd(f):
        x = S_IEXEC | S_IXGRP | S_IXOTH  # executable files
        return f.is_file() and f.stat().st_mode & x and not f.name.startswith('.')

    path = (Path(d) for d in environ['PATH'].split(':'))
    cmds = sorted([f.name for d in path for f in d.iterdir() if is_cmd(f)])

out = run('dmenu', input='\n'.join(cmds), stdout=PIPE, universal_newlines=True).stdout.strip()

if out:
    while out in cmds:
        cmds.remove(out)
    cmds = [out] + cmds

    with shelve.open(SHELF) as shelf:
        shelf['cmds'] = cmds

    run(out)
