#!/usr/bin/python2
#-*- coding: utf-8 -*-

import os, sys, re, time, shelve, unicodedata
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
    print 'Ratage de l’ouverture du shelve'
    date = {}

site = 'japanshin'
scans = ['Kenichi', 'Naruto', 'Fairy Tail', 'One Piece', 'Black Butler', 'Metallica Metalluca']

r = scans[0]
for scan in scans[1:]:
    r = r + '|' + scan

series = {
        're': re.compile(r.replace(' ','.?'),re.I),
        'titles': [(scan,re.compile(scan.replace(' ','.?'),re.I)) for scan in scans]
        }

url_rss = 'http://www.japan-shin.com/lectureenligne/reader/feeds/rss/'
url_re = re.compile(r'http://www\.japan-shin\.com/lectureenligne/reader/read/(?P<serie_url>[a-z0-9_-]*)/fr/(?P<tome>[0-9]*)/(?P<chapt>[0-9]*)/')

def run(reset=False):
    if reset:
        date[site] = time.gmtime(0)

    feed = feedparser.parse(url_rss)
    if feed['bozo']:
        rouge('bozo')
        return

    nouvelles_entrees = False
    try:
        nouvelles_entrees = date[site] < feed['entries'][0]['published_parsed']
    except IndexError:
        rouge('<DEBUG>')
        pprint.PrettyPrinter(indent=4).pprint(feed)
        rouge('</DEBUG>')

    if nouvelles_entrees:
        for entrie in feed['entries']:
            url_lel = entrie['links'][0]['href']
            url_dl = re.sub(r'/read/','/download/', url_lel)
            m = url_re.match(url_lel)
            if not m:
                print 'FAIL'
            if date[site] < entrie['published_parsed']:
                if series['re'].search(entrie['title']):
                    print '+', entrie['title'].encode('utf-8')
                    #print unicodedata.normalize('NFKD',entrie['title']).encode('ascii','ignore')
                    url_lel = entrie['links'][0]['href']
                    url_dl = re.sub(r'/read/','/download/', url_lel)
                    webbrowser.open(url_dl)
                else:
                    print '-', entrie['title'].encode('utf-8')
            elif date[site] == entrie['published_parsed']:
                vert('revenu à la dernière entrée sauvegardée sur %s.' % site)
                break
            else:
                rouge('ATTENTION il manque probablement des trucs sur %s !' % site)
                break
        date[site] = feed['entries'][0]['published_parsed']
    else:
        print '.'

if __name__ == '__main__':
    reset = False
    if not date.has_key(site):
        reset = True
    run(reset)

if date_shelve:
    date.close()
