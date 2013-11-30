#!/usr/bin/env python2
#-*- coding: utf-8 -*-

from re import findall
from subprocess import CalledProcessError, check_output
from sys import exit

return_code = 0

gst = check_output(['git', 'status', '--porcelain'])

for path in findall(r'[AM]+\s*"?(?P<name>[^"\n]*)"?\n', gst):
    check_output(['git', 'update-index', '--add', path])

    if path.endswith('.py'):
        try:
            check_output(["isort", "-p", "django", "-l", "160", path])
            check_output(['pep8', path])
            # isort modifies the files…
            check_output(['git', 'update-index', '--add', path])
        except CalledProcessError, e:
            return_code += 1
            print e.output

exit(return_code)
