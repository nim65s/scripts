#!/usr/bin/python2
#-*- coding: utf-8 -*-

#TODO: fenetres de textes dans les fenetres, pour pas faire clignoter bordures & titres

from __future__ import with_statement

import locale, curses, time, logging
from os import chdir
from sys import argv
from os.path import expanduser, join
from subprocess import *
from threading import Thread, Lock
from datetime import datetime

locale.setlocale(locale.LC_ALL, '')
code = locale.getpreferredencoding()

error = ''
lock = Lock()

LOG_PATH = expanduser('~/.logs')
logfile = join(LOG_PATH,'DVCS.log')
log = logging.getLogger('log')
log.setLevel(logging.INFO)
log.addHandler(logging.FileHandler(logfile))

YW = 40 # Largeur type d’une fenêtre
YH = 28 # Hauteur
#N = 13 # Nombre de fenetres
N = 3 # Nombre de fenetres

class NimWindow(Thread):
    def __init__(self, height, width, j, k, nbr_win_y, reste_y, dvcs, path, stdscr, max_y):
        Thread.__init__(self)
        self.path = path
        if not dvcs in ['git','hg']:
            raise AttributeError('DVCS must be git or hg. get %s' % dvcs)
        self.dvcs = dvcs
        # Fenêtre: taille, bordure
        self.ncols = width - 1 # Colonnes utiles (-1 pour la bordure droite)
        self.nlines = height - 2 # Lignes utiles (-1 pour le titre et -1 pour la bordure basse)
        begin_y = j*width
        rs = curses.ACS_VLINE
        tr = curses.ACS_VLINE
        br = curses.ACS_LRCORNER
        if j == nbr_win_y - 1:
            rs = ' '
            tr = ' '
            br = curses.ACS_HLINE
            self.ncols += 1
        if j < reste_y:
            width += 1
            self.ncols += 1
        begin_y += min(j,reste_y)
        self.win = curses.newwin(height,width,k*height,begin_y)
        self.win.border(' ',rs,' ',curses.ACS_HLINE,' ',tr,curses.ACS_HLINE,br)

        # Fenêtre: titre
        if len(dvcs)+len(path) < self.ncols + 1:
            spaces = self.ncols - len(dvcs) - len(path) - 2
            self.title = ' ' * (spaces/2) + dvcs + ': ' + path + ' ' * (spaces/2 - 2)
        else:
            title = dvcs + ': ' + path
            self.title = title[:self.ncols]
        self.win.addstr(0,1,self.title)

        # Fenêtre: lignes utiles
        self.lines = []
        for i in range(self.nlines):
            self.lines.append(' ')

    def run(self):
        chdir(expanduser(self.path))
        p = Popen([self.dvcs,'status'],stdout=PIPE)
        while 1:
            line = p.stdout.readline().strip()
            if line:
                self.addline(line)
            else:
                break
        self.addline('bépoauiebépotsrnvdljàyx.hgq')

    def addline(self, line):
        lines = []
        line = line.replace('\t','    ').decode('utf-8')
        while len(line) > self.ncols:
            if len(lines) == 0:
                lines.append(line[:self.ncols])
                line = line[self.ncols:]
            else:
                lines.append(u'↳' + line[:self.ncols-1])
                line = line[self.ncols-1:]
        if len(lines) == 0:
            lines.append(line)
        else:
            lines.append(u'↳' + line)
        for i in range(self.nlines-len(lines)):
            line = self.lines[self.nlines - i - 1 - len(lines)]
            self.lines[self.nlines - i - 1] = line + ' ' * (self.ncols - len(line))
        for i in range(len(lines)):
            line = lines[-i-1]
            self.lines[i] = line + ' ' * (self.ncols - len(line))

        self.refresh()

    def refresh(self):
        for i in range(self.nlines):
            self.win.addstr(self.nlines - i,0,self.lines[i].encode('utf-8'))
        time.sleep(0.5)
        with lock:
            self.win.refresh()


stdscr = curses.initscr()
curses.noecho()
curses.cbreak()
stdscr.keypad(1)
with lock:
    stdscr.refresh()
try:
    max_x,max_y = stdscr.getmaxyx()
    if YW > max_y:
        YW = max_y

    nbr_win_y = max_y / YW # Nombre de fenetres sur une ligne
    wid_win_y = YW + ( max_y % YW ) / ( nbr_win_y ) # leur largeur
    if nbr_win_y >= N:
        nbr_win_y = N
        wid_win_y = max_y / N #- N + 1
    reste_y = max_y - nbr_win_y * wid_win_y #+1 # ce qu’il reste

    i = 0
    j = 0
    k = 0
    while i < N:
        while j < nbr_win_y and i < N:
            t = NimWindow(YH, wid_win_y, j, k, nbr_win_y, reste_y, 'git', '~/AOC_LaTeX',stdscr, max_y)
            t.start()
            j += 1
            i += 1
        j = 0
        k += 1
    time.sleep(6)

except NameError as er:
    print er
    error = er

finally:
    curses.nocbreak()
    stdscr.keypad(0)
    curses.echo()
    curses.endwin()

print 'pipo', error
#time.sleep(1)
