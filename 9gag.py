#!/usr/bin/python2
#-*- coding: utf-8 -*-

import urllib, os
from BeautifulSoup import BeautifulSoup

try:
    fichier = open("/tmp/9gag.txt", "r")
    old_gagid = fichier.read()
    fichier.close()
except IOError:
    old_gagid = ''

url = urllib.urlopen('http://9gag.com')
soup = BeautifulSoup(url.read())
(i,last_gagid) = soup.find("li",{"class":" entry-item"}).attrs[3]

if old_gagid != last_gagid:
    os.system('chromium http://9gag.com')
    fichier = open("/tmp/9gag.txt", "w")
    fichier.write(last_gagid)
    fichier.close()
