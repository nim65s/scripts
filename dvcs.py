#!/usr/bin/python2
#-*- coding: utf-8 -*-

#TODO: fenetres de textes dans les fenetres, pour pas faire clignoter bordures & titres

import locale, curses, time, logging
from os import chdir
from sys import argv
from os.path import expanduser, join
from subprocess import *
from threading import Thread
from datetime import datetime

locale.setlocale(locale.LC_ALL, '')
code = locale.getpreferredencoding()

LOG_PATH = expanduser('~/.logs')
logfile = join(LOG_PATH,'DVCS.log')
log = logging.getLogger('log')
log.setLevel(logging.INFO)
log.addHandler(logging.FileHandler(logfile))

YW = 40 # Largeur type d’une fenêtre
YH = 28 # Hauteur
#N = 13 # Nombre de fenetres
N = 2 # Nombre de fenetres

class NimWindow():
    def __init__(self, height, width, j, k, nbr_win_y, reste_y, dvcs, path):
        self.path = path
        self.dvcs = dvcs
        # Fenêtre: taille, bordure
        self.ncols = width # Colonnes utiles
        self.nlines = height - 2 # Lignes utiles (-1 pour le titre et -1 pour la bordure basse)
        begin_y = j*width
        rs = curses.ACS_VLINE
        tr = curses.ACS_VLINE
        br = curses.ACS_LRCORNER
        if j == nbr_win_y - 1:
            rs = ' '
            tr = ' '
            br = curses.ACS_HLINE
        if j < reste_y:
            width += 1
        begin_y += min(j,reste_y)
        self.win = curses.newwin(height,width,k*height,begin_y)
        self.win.border(' ',rs,' ',curses.ACS_HLINE,' ',tr,curses.ACS_HLINE,br)

        # Fenêtre: titre
        if len(dvcs)+len(path) < self.ncols + 1:
            spaces = self.ncols - len(dvcs) - len(path) - 2
            self.title = ' ' * (spaces/2) + dvcs + ': ' + path + ' ' * (spaces/2 - spaces%2)
        else:
            title = dvcs + ': ' + path
            self.title = title[:self.ncols]
        self.win.addstr(0,1,self.title)

        # Fenêtre: lignes utiles
        self.lines = []
        for i in range(self.nlines):
            self.lines.append(' ')
        self.refresh()

    def __call__(self):
        chdir(expanduser(self.path))
        p = Popen(['cat','st'],stdout=PIPE)
        while 1:
            line = p.stdout.readline().strip()
            if line:
                self.addline(line)
            else:
                break

    def addline(self, line):
        lines = []
        #log.info('addline %s' % line)
        while len(line) > self.ncols:
            lines.append(line[:self.ncols])
            #log.info('→' + line[:self.ncols] + '−' + line[self.ncols:])
            line = line[self.ncols:]
        lines.append(line)
        #log.info(line)
        for i in range(self.nlines-len(lines)):
            #print 'ICI', i, self.nlines
            self.lines[self.nlines - i - 1] = self.lines[self.nlines - i - 1 - len(lines)]
        for i in range(len(lines)):
            self.lines[i] = lines[-i-1]

        #log.info('LINES')
        #for i in range(len(self.lines)):
            #log.info(self.lines[i])
        self.refresh()

    def refresh(self):
        for i in range(self.nlines):
            self.win.addstr(self.nlines - i,0,self.lines[i])
            self.win.refresh()
            time.sleep(1)
        #self.win.clear()#TODO refresh/clear
        self.win.refresh()#TODO refresh/clear

stdscr = curses.initscr()
curses.noecho()
curses.cbreak()
stdscr.keypad(1)
stdscr.refresh()

max_x,max_y = stdscr.getmaxyx()

nbr_win_y = max_y / YW # Nombre de fenetres sur une ligne
if nbr_win_y > N:
    nbr_win_y = N
wid_win_y = YW + ( max_y % YW ) / ( nbr_win_y ) # leur largeur
reste_y = max_y - nbr_win_y * wid_win_y #+1 # ce qu’il reste

i = 0
j = 0
k = 0
while i < N:
    while j < nbr_win_y and i < N:
        Thread(target = NimWindow(YH, wid_win_y, j, k, nbr_win_y, reste_y, 'git', '~/AOC_LaTeX')).start()
        j += 1
        i += 1
    j = 0
    k += 1


time.sleep(6)
#stdscr.addstr('bla')
#stdscr.refresh()
#time.sleep(1)
#stdscr.addstr(stdscr.getmaxyx().__str__())
#stdscr.refresh()
#time.sleep(1)

#begin_x = 20
#begin_y = 7
#height = 5
#width = 40
#win = curses.newwin(height, width, begin_y, begin_x)
#win.box()
#win.refresh()
#time.sleep(1)
#win.addstr('blabla')
#win.refresh()
#time.sleep(1)
#win.addstr(win.getmaxyx().__str__())
#win.refresh()
#time.sleep(1)
#win.addstr('\n1234567890123456789012345678901234567890')
#win.refresh()
#time.sleep(3)

curses.nocbreak()
stdscr.keypad(0)
curses.echo()
curses.endwin()

print 'pipo'
#time.sleep(1)
