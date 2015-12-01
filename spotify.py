#!/usr/bin/env python3

from argparse import ArgumentParser

from dbus import Interface, SessionBus

parser = ArgumentParser(description='wrapper DBus pour Spotify')
parser.add_argument('action', nargs=1, choices=['play', 'pause', 'playpause', 'next', 'previous'])
action = parser.parse_args().action[0]

bus = SessionBus()
proxy = bus.get_object('org.mpris.MediaPlayer2.spotify', '/org/mpris/MediaPlayer2')
interface = Interface(proxy, dbus_interface='org.mpris.MediaPlayer2.Player')

if action in ['pause', 'play']:  # Workaround spotify’s bad implementation of Play…
    interface.Pause()
if action in ['playpause', 'play']:
    interface.PlayPause()
elif action == 'next':
    interface.Next()
elif action == 'previous':
    interface.Previous()
