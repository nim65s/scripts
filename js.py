#!/usr/bin/python2
#-*- coding: utf-8 -*-

from __future__ import print_function

import os, sys, re, time, shelve, datetime
import feedparser, urllib, webbrowser
from BeautifulSoup import BeautifulSoup

try:
    date = shelve.open('%s/.js_shelve' % os.environ['HOME'], writeback=True)
except:
    date = {}

site = 'japanshin'
scans = ['Kenichi', 'Naruto', 'Fairy Tail', 'One Piece', 'Black Butler', 'Claymore']

r = '^' + scans[0]
for scan in scans[1:]:
    r = r + '|^' + scan

series = {
        're': re.compile(r,re.I),
        'titles': [(scan,re.compile(scan.replace(' ','*'),re.I)) for scan in scans]
        }

url_rss = 'http://www.japan-shin.com/lectureenligne/reader/feeds/rss/'
url_re = re.compile(r'http://www\.japan-shin\.com/lectureenligne/reader/read/(?P<serie_url>[a-z0-9_-]*)/fr/(?P<tome>[0-9]*)/(?P<chapt>[0-9]*)/')

def checkChapters():
    pass

def run():
    if not date.has_key(site) or len(sys.argv) > 1:
        date[site] = time.gmtime(0)

    feed = feedparser.parse(url_rss)
    if date[site] < feed['entries'][0]['published_parsed']:
        print(datetime.datetime.now())
        for entrie in feed['entries']:
            url_lel = entrie['links'][0]['href']
            url_dl = re.sub(r'/read/','/download/', url_lel)
            m = url_re.match(url_lel)
            if not m:
                print('FAIL')
            if date[site] < entrie['published_parsed']:
                if series['re'].search(entrie['title']):
                    print(entrie['title'], '…')
                    url_lel = entrie['links'][0]['href']
                    url_dl = re.sub(r'/read/','/download/', url_lel)
                    webbrowser.open(url_dl)
                    
                else:
                    print('- %s' % entrie['title'])
            elif date[site] == entrie['published_parsed']:
                print('\033[1;32mrevenu à la dernière entrée sauvegardé sur %s.\033[0m' % site)
                break
            else:
                print('ATTENTION il manque probablement des trucs sur %s !' % site)
                break
        date[site] = feed['entries'][0]['published_parsed']
    else:
        print('.', end='')

    date.close()

if __name__ == '__main__':
    run()

