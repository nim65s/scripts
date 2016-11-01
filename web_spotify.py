#!/usr/bin/env python

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
        return '<h1>%s</h1><h2>%s</h2>%s' % (artist, song, str(lyrics)[1:-1] if lyrics else req.url)


if __name__ == '__main__':
    client = SpotifyLocalHTTPClient()
    print(html2text.html2text(client.lyrics()))
