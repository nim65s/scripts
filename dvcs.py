#!/usr/bin/python2
#-*- coding: utf-8 -*-

#TODO: fenetres de textes dans les fenetres, pour pas faire clignoter bordures & titres

from __future__ import with_statement

import locale, curses, time, logging
from os import chdir, putenv
from sys import argv
from os.path import expanduser, join
from subprocess import *
from threading import Thread, Lock
from datetime import datetime

locale.setlocale(locale.LC_ALL, '')
code = locale.getpreferredencoding()

putenv('EDITOR', 'gvim --nofork')

error = ''
curses_lock = Lock()
chdir_lock = Lock()

LOG_PATH = expanduser('~/.logs')
logfile = join(LOG_PATH,'DVCS.log')
log = logging.getLogger('log')
log.setLevel(logging.INFO)
log.addHandler(logging.FileHandler(logfile))

git=['~/N7','~/dotfiles','~/scripts','~/CV','~/JE','~/gdf','~/net7/bots/pipobot']
hg=['~/net7/admin','~/net7/bots/pipobot-modules','~/net7/doc','~/net7/docs','~/net7/portail','~/net7/scripts_live']

YW = 40 # Largeur type d’une fenêtre
YH = 30 # Hauteur
N = len(git) + len(hg) # Nombre de fenetres

STATUS = False
PULL   = False
COMMIT = False
PUSH   = False

if len(argv) > 1:
    if argv[1] == 'status':
        STATUS = True
    elif argv[1] == 'pull':
        PULL = True
    elif argv[1] == 'commit':
        PULL = True
        COMMIT = True
    elif argv[1] == 'push':
        PULL = True
        COMMIT = True
        PUSH = True
else:
    STATUS = True

cmd = {
        'status': {
            'git': ['git','status'],
            'hg' : ['hg','st'],
            'go' : STATUS,
            },
        'pull': {
            'git': ['git','pull'],
            'hg' : ['hg','pull','-u'],
            'go' : PULL,
            },
        'commit': {
            'git': ['git','commit','-a'],
            'hg' : ['hg','ci'],
            'go' : COMMIT,
            },
        'push': {
            'git': ['git','push'],
            'hg' : ['hg','push'],
            'go' : PUSH,
            },
        }

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
        self.win.addstr(0,1,self.title,curses.color_pair(1)|curses.A_BOLD)

        # Fenêtre: lignes utiles
        self.lines = []
        for i in range(self.nlines):
            self.lines.append(' '*self.ncols)
        self.refresh()

    def run(self):
        for k in cmd.keys():
            if cmd[k]['go']:
                with chdir_lock:
                    chdir(expanduser(self.path))
                    p = Popen(cmd[k][self.dvcs],stdout=PIPE, stderr=STDOUT)
                while 1:
                    line = p.stdout.readline().strip()
                    if line:
                        self.addline(line)
                    else:
                        break

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
        with curses_lock:
            self.win.refresh()

stdscr = curses.initscr()
curses.start_color()
curses.use_default_colors()
curses.init_pair(1, curses.COLOR_GREEN, curses.COLOR_BLACK)
curses.noecho()
curses.cbreak()
stdscr.keypad(1)
with curses_lock:
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
    threads = []
    while i < len(git):
        while j < nbr_win_y and i < len(git):
            threads.append(NimWindow(YH, wid_win_y, j, k, nbr_win_y, reste_y, 'git', git[i],stdscr, max_y))
            threads[i].start()
            j += 1
            i += 1
        if j == nbr_win_y:
            j = 0
            k += 1
    while i < N:
        while j < nbr_win_y and i < N:
            threads.append(NimWindow(YH, wid_win_y, j, k, nbr_win_y, reste_y, 'hg', hg[i-len(git)],stdscr, max_y))
            threads[i].start()
            j += 1
            i += 1
        j = 0
        k += 1

    for thread in threads:
        thread.join()
    if STATUS:
        stdscr.getch()

except :
    pass

finally:
    curses.nocbreak()
    stdscr.keypad(0)
    curses.echo()
    curses.endwin()
