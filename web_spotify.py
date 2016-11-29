#!/usr/bin/env python

from time import sleep

import html2text
import requests
from bs4 import BeautifulSoup


class SpotifyLocalHTTPClient(object):
    def __init__(self):
        self.session = requests.Session()
        self.session.verify = False
        self.session.headers = {'Origin': 'https://open.spotify.com'}
        for port in range(4370, 4385):
            try:
                self.url = 'https://localhost:%i/' % port
                self.session.get(self.url)
                break
            except requests.exceptions.ConnectionError:
                pass
        else:
            raise RuntimeError('Is Spotify runing ?')
        self.session.params = {'csrf': self.get_json('simplecsrf/token', rejectUnauthorized='false')['token'],
                               'oauth': requests.get('https://open.spotify.com/token').json()['t']}

    def get_json(self, url, **params):
        return self.session.get('%s%s.json' % (self.url, url), params=params).json()

    def status(self):
        return self.get_json('remote/status')

    def pause(self):
        playing = self.status()['playing']
        return self.get_json('remote/pause', pause=str(playing).lower())

    def track(self):
        track = self.status()['track']
        return track['artist_resource']['name'], track['track_resource']['name']

    def lyrics(self):
        artist, song = self.track()
        req = requests.get("http://lyrics.wikia.com/%s:%s" % (artist, song.split('-')[0].title()))
        lyrics = BeautifulSoup(req.content, 'html.parser').find_all('div', class_='lyricbox')
        if not lyrics:
            search = BeautifulSoup(req.content, 'html.parser').find_all('a', class_='external text')
            if search:
                req_s = requests.get(search[0].attrs['href'])
                search_page = BeautifulSoup(req_s.content, 'html.parser').find_all('a', class_='result-link')
                if search_page:
                    req_final = requests.get(search_page[0].attrs['href'])
                    lyrics = BeautifulSoup(req_final.content, 'html.parser').find_all('div', class_='lyricbox')
        return '<h1>%s</h1><h2>%s</h2>%s' % (artist, song, str(lyrics)[1:-1] if lyrics else req.url)


if __name__ == '__main__':
    client = SpotifyLocalHTTPClient()
    track, artist = '', ''
    while True:
        if (track, artist) != client.track():
            track, artist = client.track()
            print(html2text.html2text(client.lyrics()))
        sleep(1)
