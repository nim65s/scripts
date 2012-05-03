#!/usr/bin/python2
#-*- coding: utf-8 -*-

import os, webbrowser, feedparser

if not os.system("xset q|tail -n 1|grep -q 'On'"):
    try:
        fichier = open(os.path.expanduser("~/.9gag"), "r")
        old_gagtitle = fichier.read()
        fichier.close()
    except IOError:
        old_gagtitle = ''

    feed = feedparser.parse('http://9gag.com/rss/site/feed.rss')
    last_gagtitle = feed["items"][0]["title"]

    if old_gagtitle != last_gagtitle:
        webbrowser.open('http://9gag.com')
        fichier = open("%s/.9gag" % os.environ['HOME'], "w")
        fichier.write(last_gagtitle)
        fichier.close()
else:
    print 'absent'
