#!/usr/bin/env python

# ~/.lbc_queries.json:
# {"c4-5k-2011-man": "https://www.leboncoin.fr/voitures/offres/midi_pyrenees/bonnes_affaires/?th=1&q=picasso…
#
# crontab:
# ./scripts/lbc.py && jq . .lbc_results.json > .lbc_new && diff -u .lbc_old .lbc_new && mv .lbc_new .lbc_old


import json
from os.path import expanduser
from pathlib import Path

import requests
from bs4 import BeautifulSoup
from html2text import html2text

# from datetime import datetime


RESULTS_FILE = Path(expanduser('~/.lbc_results.json'))
QUERY_FILE = Path(expanduser('~/.lbc_queries.json'))

if __name__ == '__main__':
    with QUERY_FILE.open() as f:
        urls = json.load(f)

    if RESULTS_FILE.is_file():
        with RESULTS_FILE.open() as f:
            results = json.load(f)
    else:
        print('first email')
        results = {key: {} for key in urls.keys()}

    for key, url in urls.items():
        soup = BeautifulSoup(requests.get(url).content, 'html.parser')
        for link in soup.find_all('a', class_='list_item'):
            href = link.attrs['href']
            if href.startswith('//'):
                href = 'https:' + href
            if href not in results[key]:
                print(f'Nouveau résultat pour {key}: {href}')
                results[key][href] = {}
        for url, data in results[key].items():
            r = requests.get(url)
            if r.status_code != 200:
                continue
            sousoup = BeautifulSoup(r.content, 'html.parser')
            results[key][url] = {
                'titre': sousoup.find('h1').text.strip(),
                'prix': sousoup.find('span', class_='_1F5u3').text.strip(),
                # 'date': datetime.strptime(sousoup.find('div', class_='_3Pad-').text, '%d/%m/%Y à %Hh%M'),
                'date': sousoup.find('div', class_='_3Pad-').text.strip(),
                'critères': [s.text.strip() for s in sousoup.find_all(class_='_3Jxf3')],
                'description': [l.strip() for l in html2text(str(sousoup.find(class_='_2wB1z'))).split('\n') if l],
            }

    with RESULTS_FILE.open('w') as f:
        json.dump(results, f)
