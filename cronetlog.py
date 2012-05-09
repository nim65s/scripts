#!/usr/bin/python2
#-*- coding: utf-8 -*-

from os import putenv, mkdir
from sys import argv
from os.path import expanduser, isdir, join
from subprocess import *
from datetime import datetime

usage = """ Script appelé par Cron pour lancer les autres scripts.
Il sert à mettre les bonnes variables et à logger.
Utilisation : $0 script """

putenv('DISPLAY', ':0.0')
putenv('BROWSER', 'chromium')

PATH = expanduser('~/scripts')
LOG_PATH = expanduser('~/.logs')
if not isdir(LOG_PATH):
    mkdir(LOG_PATH)

if len(argv) > 1:
    logfile = open(join(LOG_PATH,'%s.log' % argv[1]),'a')
    errfile = open(join(LOG_PATH,'%s.err' % argv[1]),'a')

    args = [join(PATH,'%s' % argv[1])] + argv[2:]
    logger = [join(PATH,'logger.sh')]

    p = Popen(args, stdout=PIPE, stderr=PIPE)
    plog = Popen(logger, stdin=p.stdout, stdout=logfile)
    perr = Popen(logger, stdin=p.stderr, stdout=errfile)

    p.stdout.close()
    p.stderr.close()
    logfile.close()
    errfile.close()
else:
    print usage
