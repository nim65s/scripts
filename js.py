#!/usr/bin/python2
#-*- coding: utf-8 -*-

from __future__ import print_function

import os, sys, re, time, shelve, datetime
import feedparser, urllib, webbrowser, pprint
from BeautifulSoup import BeautifulSoup

from couleurs import *

reset=False
sleep=0
date_shelve = False

try:
    date = shelve.open(os.path.expanduser('~/.js_shelve'), writeback=True)
    date_shelve = True
except:
    print('Ratage de l’ouverture du shelve')
    date = {}

site = 'japanshin'
scans = ['Kenichi', 'Naruto', 'Fairy Tail', 'One Piece', 'Black Butler', 'Claymore', 'Metallica Metalluca']

r = scans[0]
for scan in scans[1:]:
    r = r + '|' + scan

series = {
        're': re.compile(r.replace(' ','.?'),re.I),
        'titles': [(scan,re.compile(scan.replace(' ','.?'),re.I)) for scan in scans]
        }

url_rss = 'http://www.japan-shin.com/lectureenligne/reader/feeds/rss/'
url_re = re.compile(r'http://www\.japan-shin\.com/lectureenligne/reader/read/(?P<serie_url>[a-z0-9_-]*)/fr/(?P<tome>[0-9]*)/(?P<chapt>[0-9]*)/')

def checkChapters():
    pass

def run(reset=False):
    if reset:
        date[site] = time.gmtime(0)

    feed = feedparser.parse(url_rss)
    if feed['bozo']:
        rouge(u'Bozo')
        return

    nouvelles_entrees = False
    try:
        nouvelles_entrees = date[site] < feed['entries'][0]['published_parsed']
    except IndexError:
        rouge('<DEBUG>')
        pprint.PrettyPrinter(indent=4).pprint(feed)
        rouge('</DEBUG>')

    if nouvelles_entrees:
        print(datetime.datetime.now())
        for entrie in feed['entries']:
            url_lel = entrie['links'][0]['href']
            url_dl = re.sub(r'/read/','/download/', url_lel)
            m = url_re.match(url_lel)
            if not m:
                print('FAIL')
            if date[site] < entrie['published_parsed']:
                if series['re'].search(entrie['title']):
                    if date_shelve:
                        print(entrie['title'], '…')
                        url_lel = entrie['links'][0]['href']
                        url_dl = re.sub(r'/read/','/download/', url_lel)
                        webbrowser.open(url_dl)
                    else:
                        print
                    
                else:
                    print('- %s' % entrie['title'])
            elif date[site] == entrie['published_parsed']:
                vert('revenu à la dernière entrée sauvegardé sur %s.' % site)
                break
            else:
                rouge('ATTENTION il manque probablement des trucs sur %s !' % site)
                break
        date[site] = feed['entries'][0]['published_parsed']
    else:
        if sleep == 0:
            print('rien')
        else:
            print('.', end='')

if __name__ == '__main__':
    if len(sys.argv) > 1:
        try:
            sleep = int(sys.argv[1])
            reset = False
        except ValueError:
            sleep = 0
            reset = True
    if not date.has_key(site):
        reset = True
    if sleep == 0:
        run(reset)
    else:
        try:
            while 1:
                run(reset)
                time.sleep(sleep)
        except KeyboardInterrupt:
            pass

if date_shelve:
    date.close()
