#!/usr/bin/env python2
# -*- coding: utf-8 -*-

from __future__ import unicode_literals

from subprocess import CalledProcessError, check_output
from sys import exit

return_code = 0


for path in check_output(['git', 'status', '--porcelain']).split('\n'):
    path = path.strip().split()
    if not path:
        continue
    if path[0] in 'AMR':
        debut_path = 1
        if path[0] == 'R':
            debut_path = 3
        path = ' '.join(path[debut_path:])
        if path.endswith('.py'):
            try:
                check_output(["isort", "-p", "django", "-p", "pipobot", "-l", "160", path])
                check_output(['pep8', path])
                # isort modifies the files…
                check_output(['git', 'update-index', '--add', path])
            except CalledProcessError, e:
                return_code += 1
                print e.output
        else:
            check_output(['git', 'update-index', '--add', path])
    elif path[0] != 'D':
        print path

exit(return_code)
