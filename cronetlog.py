#!/usr/bin/python2
#-*- coding: utf-8 -*-

from os import putenv, mkdir
from sys import argv
from os.path import expanduser, isdir, join
from subprocess import *
from datetime import datetime
from threading import Thread
import logging, unicodedata

usage = """ Script appelé par Cron pour lancer les autres scripts.
Il sert à mettre les bonnes variables et à logger.
Utilisation : $0 script """

putenv('DISPLAY', ':0')
putenv('BROWSER', 'chromium')

PATH = expanduser('~/scripts')
LOG_PATH = expanduser('~/.logs')

if not isdir(LOG_PATH):
    mkdir(LOG_PATH)

logfile = join(LOG_PATH,'%s.log' % argv[1])
errfile = join(LOG_PATH,'%s.err' % argv[1])

log = logging.getLogger('log')
err = logging.getLogger('err')
log.setLevel(logging.INFO)
err.setLevel(logging.ERROR)
log.addHandler(logging.FileHandler(logfile))
err.addHandler(logging.FileHandler(errfile))

def now():
    return datetime.now().strftime('%F %T')

def logThread():
    while 1:
        line = p.stdout.readline().strip()
        if line:
            line = line.decode('utf-8','ignore')
            line = u'[%s] %s' % (now(),line)
            line = unicodedata.normalize('NFKD', line)
            line = line.encode('ascii','ignore')
            log.info(line)
        else:
            break

def errThread():
    while 1:
        line = p.stderr.readline().strip()
        if line:
            line = line.decode('utf-8','ignore')
            line = u'[%s] %s' % (now(),line)
            line = unicodedata.normalize('NFKD', line)
            line = line.encode('ascii','ignore')
            err.error(line)
        else:
            break

if len(argv) > 1:
    args = [join(PATH,'%s' % argv[1])] + argv[2:]

    p = Popen(args, stdout=PIPE, stderr=PIPE)

    Thread(target = logThread).start()
    Thread(target = errThread).start()
else:
    print usage
