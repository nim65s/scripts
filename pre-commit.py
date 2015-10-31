#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import print_function, unicode_literals

from os import getenv
from subprocess import check_output
from sys import exit

from flake8.hooks import git_hook
from isort import SortImports

COMPLEXITY = getenv('FLAKE8_COMPLEXITY', 10)
STRICT = getenv('FLAKE8_STRICT', False)
IGNORE = getenv('FLAKE8_IGNORE')
LAZY = getenv('FLAKE8_LAZY', False)


return_code = 0


for path in check_output(['git', 'status', '--porcelain']).decode('utf-8').split('\n'):
    path = path.strip().split()
    if not path:
        continue
    if path[0] in 'AMR':
        debut_path = 1
        if path[0] == 'R':
            debut_path = 3
        path = ' '.join(path[debut_path:])
        if path.endswith('.py'):
            SortImports(path)
        # isort modifies the files…
        check_output(['git', 'update-index', '--add', path])
    elif path[0] != 'D':
        print(path)

exit(return_code + git_hook(complexity=COMPLEXITY, strict=STRICT, ignore=IGNORE, lazy=LAZY))
