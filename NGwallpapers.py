#!/usr/bin/python3

# ##########################################################
# NGwallpapers.py
# by Morgan LEFIEUX - 2011 - http://gerard.geekandfree.org
# v0.2
# This file is under a Creative Commons BY-NC-SA licence
# http://creativecommons.org/licenses/by-nc-sa/2.0/fr/
# ##########################################################
# Totally inspired by Romain BOCHET's scripts in bash, thanks to him !
# http://blog.stackr.fr/2011/01/rotation-fond-ecrans-wallpapers-national-geographic/
# ##########################################################

# Translated to Python3 by Guilhem "Nim65s" Saurel

import argparse
from datetime import datetime
from os.path import expanduser
from pathlib import Path

import requests

# Where the wallpapers will be saved
destdir = Path(expanduser("~/images/wallpapers"))

URL = "http://ngm.nationalgeographic.com/wallpaper/img/%swallpaper-%i_1600.jpg"


def get(year, month):
    date = datetime(year, month, 1)
    print("Downloading wallpapers from %s…" % date.strftime("%B %Y"))
    i = 1
    while True:
        url = URL % (date.strftime("%Y/%m/%b%y").lower(), i)
        r = requests.get(url, stream=True)
        if r.status_code != 200:
            break
        name = "%s-%i.jpg" % (date.strftime("%Y-%m"), i)
        path = destdir / name
        if not path.exists():
            with path.open('wb') as f:
                for chunk in r:
                    f.write(chunk)
            print("  New wallpaper:", path)
        i += 1


def main(year, month=0):
    year = year[0] + 2000
    if month == 0:
        for month in range(1, 13):
            get(year, month)
    else:
        get(year, month)


if __name__ == "__main__":
    if not destdir.exists():
        destdir.mkdir()

    parser = argparse.ArgumentParser(description="Download wallpapers from NG")
    parser.add_argument('year', type=int, nargs=1, choices=range(9, datetime.today().year - 2000))
    parser.add_argument('month', type=int, nargs='?', choices=range(13), default=0)
    main(**vars(parser.parse_args()))
