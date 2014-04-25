#!/usr/bin/python2
# -*- coding: utf-8 -*-

import re
import shelve
import time
import webbrowser
from os import listdir
from os.path import expanduser

import feedparser

scans = listdir(expanduser('~/Scans'))
series = re.compile('|'.join(scans).replace(' ', '.?'), re.I)

sites = [
    ('japanshin', 'http://www.japan-shin.com/lectureenligne/'),
    ('kangaryu', 'http://kangaryu-team.fr/'),
    ]


def run(nom, prefix_url, timestamp):
    print nom
    url_rss = prefix_url + 'reader/feeds/rss/'
    url_re = re.compile(r'%sreader/read/(?P<serie_url>[a-z0-9_]*)/fr/(?P<tome>\d*)/(?P<chapitre>\d+)/' % prefix_url.replace('.', '\.'))
    # TODO: Gestion de ces tome / chapitre

    feed = feedparser.parse(url_rss)
    if feed['bozo']:
        print 'bozo'
        return

    for entrie in feed['entries']:
        if timestamp < entrie['published_parsed']:
            if series.search(entrie['title']):
                print '+', entrie['title'].encode('utf-8')
                webbrowser.open(re.sub(r'/read/', '/download/', entrie['links'][0]['href']))
            else:
                print '-', entrie['title'].encode('utf-8')
        elif timestamp == entrie['published_parsed']:
            print 'revenu à la dernière entrée sauvegardée sur %s.' % nom
            break
        else:
            print 'attention il manque probablement des trucs sur %s !' % nom
            break
    return feed['entries'][0]['published_parsed']


if __name__ == '__main__':
    try:
        timestamps = shelve.open(expanduser('~/.js_shelve'), writeback=True)
        date_shelve = True
    except:
        print 'Ratage de l’ouverture du shelve'
        timestamps = {}
        date_shelve = False

    for nom, prefix_url in sites:
        if nom in timestamps:
            timestamp = timestamps[nom]
        else:
            timestamp = time.gmtime(0)
        timestamps[nom] = run(nom, prefix_url, timestamp)

    if date_shelve:
        timestamps.close()
