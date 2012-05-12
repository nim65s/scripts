#!/usr/bin/python2
#-*- coding: utf-8 -*-

from os import putenv, mkdir
from sys import argv
from os.path import expanduser, isdir, join
from subprocess import *
from datetime import datetime
import logging

logging.basicConfig(level=logging.INFO)


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
    #logfile = open(join(LOG_PATH,'%s.log' % argv[1]),'a')
    #errfile = open(join(LOG_PATH,'%s.err' % argv[1]),'a')
    #print logfile.encoding
    #logfile.encoding = 'utf-8'
    #print logfile.encoding

    args = [join(PATH,'%s' % argv[1])] + argv[2:]
    #logger = [join(PATH,'logger.sh')]

    p = Popen(args, stdout=PIPE, stderr=PIPE)

    while 1:
        log = p.stdout.readline()
        err = p.stderr.readline()
        exitcode = p.poll()
        if (not log) and (not err) and (exitcode is not None):
            break
        log = log[:-1]
        err = err[:-1]
        if log:
            logging.info("[%s] %s"% (datetime.now().strftime('%F %T'),log))
        if err:
            logging.error("[%s] %s"% (datetime.now().strftime('%F %T'),err))

    #plog = Popen(logger, stdin=p.stdout, stdout=logfile)
    #perr = Popen(logger, stdin=p.stderr, stdout=errfile)

    #p.stdout.close()
    #p.stderr.close()
    #logfile.close()
    #errfile.close()
else:
    print usage
