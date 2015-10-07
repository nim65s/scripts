#!/usr/bin/env python

import shelve
from os import environ
from os.path import expanduser
from pathlib import Path
from stat import S_IEXEC, S_IXGRP, S_IXOTH
from subprocess import PIPE, run

with shelve.open(expanduser('~/.cache/demunim')) as shelf:
    if 'cmds' not in shelf:
        x = S_IEXEC | S_IXGRP | S_IXOTH
        path = (Path(d) for d in environ['PATH'].split(':'))
        shelf['cmds'] = sorted([f.name for d in path for f in d.iterdir() if f.is_file() and f.stat().st_mode & x])
    out = run(['dmenu'], input='\n'.join(shelf['cmds']), stdout=PIPE, universal_newlines=True).stdout.strip()
    if out:
        if out in shelf['cmds']:
            shelf['cmds'].remove(out)
        shelf['cmds'] = [out] + shelf['cmds']
if out:
    run(out)
