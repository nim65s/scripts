#!/usr/bin/env python2
# -*- coding: utf-8

import sys
import struct
from collections import deque

print('arecord -f S16_LE  -t raw -r 16000 | ./vumetre.py')

buff = 4000
liste = deque()
count = 0
somme = 0
maximum = 0

while True:
    val = sys.stdin.read(2)
    val = struct.unpack('<h',val)[0]
    val = abs(val)
    liste.append(val)

    somme = somme + val
    count += 1
    if count > buff:
        somme = somme - liste.popleft()
    moyenne = somme / buff
    if moyenne > maximum:
            maximum = moyenne
    print(moyenne)
