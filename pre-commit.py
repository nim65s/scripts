#!/usr/bin/env python2
# -*- coding: utf-8 -*-

from subprocess import CalledProcessError, check_output
from sys import exit

return_code = 0


for path in check_output(['git', 'status', '--porcelain']).split('\n'):
    if path.startswith(' A ') or path.startswith('M  '):
        path = path[3:]
        if path.endswith('.py'):
            try:
                check_output(["isort", "-p", "django", "-l", "160", path])
                check_output(['pep8', path])
                # isort modifies the files…
                check_output(['git', 'update-index', '--add', path])
            except CalledProcessError, e:
                return_code += 1
                print e.output
        else:
            check_output(['git', 'update-index', '--add', path])
    else:
        print path

exit(return_code)
