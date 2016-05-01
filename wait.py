#!/usr/bin/env python

from fcntl import ioctl
from struct import unpack
from sys import stdout
from time import sleep

from termios import TIOCGWINSZ


def wait(index=0, sleep_time=0.25, symbols=['→', '↘', '↓', '↙', '←', '↖', '↑', '↗'], text=""):
    width = unpack('HH', ioctl(stdout.fileno(), TIOCGWINSZ, '0000'))[1]
    stdout.write('\r%s %s%s' % (text, symbols[index], ' ' * (width - len(text) - 3)))
    stdout.flush()
    sleep(sleep_time)
    return (index + 1) % len(symbols)

if __name__ == '__main__':
    index = 0
    for i in range(25):
        index = wait(index, text='waiting…')
