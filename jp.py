#!/usr/bin/python

import os
import re
from os.path import expanduser

import requests

from bs4 import BeautifulSoup
from pathlib import Path


def num(truc):
    found = re.findall('\d+', str(truc))
    if len(found) == 1:
        return int(found[0])

home = Path(expanduser('~'))
scandir = home / 'Scans'
lectdir = home / 'Lecture'

series = [d.name for d in scandir.iterdir() if d.is_dir()]
styles = ['shonen', 'shojo', 'seinen', 'ecchi', 'webcomics']
url = 'http://jenova-project.com/'


for style in styles:
    print(style.center(80, '*'))
    r = requests.get(url + style)
    r.raise_for_status()
    b = BeautifulSoup(r.text)
    series_dispo = [c.attrs['href'][:-1] for c in b.find_all('a')]
    for serie in series:
        slug = serie.lower().replace(' ', '_')
        slugshort = slug[:20] + '..' if len(slug) > 20 else slug
        if slugshort in series_dispo:
            print(slug.center(80, '-'))
            # Chapitres déjà lus:
            chapitres_lus = []
            for d in (scandir / serie).iterdir():
                if d.parts[-1].startswith('Tome'):
                    chapitres_lus.extend([int(c.parts[-1]) for c in d.iterdir()])
                elif d.parts[-1] != 'HS':
                    chapitres_lus.append(int(d.parts[-1]))

            # Recherche des autres:
            r = requests.get(url + style + '/' + slug)
            r.raise_for_status()
            b = BeautifulSoup(r.text)
            tomes_dispo = [c.attrs['href'] for c in b.find_all('a') if c.attrs['href'].startswith('tome')]
            for tome in tomes_dispo:
                r = requests.get(url + style + '/' + slug + '/' + tome)
                r.raise_for_status()
                b = BeautifulSoup(r.text)
                chapitres_dispo = [c.attrs['href'] for c in b.find_all('a') if c.attrs['href'].startswith('chapitre')]
                for chapitre in chapitres_dispo:
                    numero = num(chapitre)
                    if numero not in chapitres_lus:
                        lecture_path = lectdir / serie / 'Tome {0}'.format(num(tome)) / str(numero)
                        if not lecture_path.is_dir():
                            lecture_path.mkdir(parents=True)

                        r = requests.get(url + style + '/' + slug + '/' + tome + chapitre)
                        r.raise_for_status()
                        b = BeautifulSoup(r.text)
                        images = [i.attrs['href'] for i in b.find_all('a') if i.attrs['href'].lower().endswith(('.jpg', '.png', '.bmp'))]
                        for image in images:
                            image_url = url + style + '/' + slug + '/' + tome + chapitre + image

                            os.spawnlp(os.P_NOWAIT, 'wget', 'wget', image_url, '-O', str(lecture_path / str(image)), '-nv')
