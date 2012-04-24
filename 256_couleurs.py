#!/usr/bin/python2
#-*- coding: utf-8 -*-

from __future__ import print_function

for i in range(8):
    print('\033[38;5;%im %i ' % (i,i),end='')
print()
for i in range(8,10):
    print('\033[38;5;%im %i ' % (i,i),end='')
for i in range(10,16):
    print('\033[38;5;%im%i ' % (i,i),end='')

print("\n")

for i in range(6):
    for j in range(6):
        for k in range(6):
            l = 16+k+6*j+36*i
            print('\033[38;5;%im ' % l,end='')
            if l < 100:
                print(' ',end='')
            print(l,end='')
        print()
    print()

for i in range(232,256):
    print('\033[38;5;%im%i ' % (i,i),end='')

print()
