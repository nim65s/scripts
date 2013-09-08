#!/usr/bin/python
# Based on an idea of https://github.com/vigneshwaranr/bd

from os import getcwd, chdir
from sys import argv

if len(argv) != 2:
    print('I need an hint, and only one…')
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
        print("I didn't found a parent directory starting with %s" % arg)
