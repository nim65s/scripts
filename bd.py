#!/usr/bin/python
# Based on an idea of https://github.com/vigneshwaranr/bd

from os import chdir, getcwd
from sys import argv, stderr

if len(argv) != 2:
    stderr.write('I need an hint, and only one…\n')
    print('.')
else:
    newpwd = './'
    arg = argv[1]

    for parent in reversed(getcwd().split('/')):
        if parent.startswith(arg):
            chdir(newpwd)
            print(getcwd())
            break
        else:
            newpwd += '../'
    else:
        stderr.write("I didn't found a parent directory starting with %s\n" % arg)
        print('.')
