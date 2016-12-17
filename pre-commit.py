#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import print_function, unicode_literals

from subprocess import check_output
from sys import exit

from flake8.main import git
from isort import SortImports

for path in check_output(['git', 'status', '--porcelain']).decode('utf-8').split('\n'):
    path = path.strip().split()
    if not path:
        continue
    if path[0] in 'AMR':
        path = ' '.join(path[3 if path[0] == 'R' else 1:])
        if path.endswith('.py'):
            SortImports(path)
            # isort modifies the files…
            check_output(['git', 'update-index', '--add', path])
    elif path[0] != 'D':
        print(path)

exit(git.hook(strict=True, lazy=True))
