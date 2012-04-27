#!/usr/bin/python2
#-*- coding: utf-8 -*-

from __future__ import print_function

style = [0,1,3,4]
for a in style:
    print('\033[%0m ', end='')
    print('\033[%im' % a, end='')
    for i in range(8):
        print('\033[38;5;%im %i ' % (i,i),end='')
print()
for a in style:
    print('\033[%0m ', end='')
    print('\033[%im' % a, end='')
    for i in range(8,10):
        print('\033[38;5;%im %i ' % (i,i),end='')
    print('\033[%0m', end='')
    print('\033[%im' % a, end='')
    for i in range(10,16):
        print('\033[38;5;%im%i ' % (i,i),end='')

print("\n")

for i in range(6):
    for j in range(6):
        for a in style:
            print('\033[%0m ', end='')
            print('\033[%im' % a, end='')
            for k in range(6):
                l = 16+k+6*j+36*i
                print('\033[38;5;%im ' % l,end='')
                if l < 100:
                    print(' ',end='')
                print(l,end='')
        print()
    print()

for a in style:
    print('\033[%0m ', end='')
    print('\033[%im' % a, end='')
    for i in range(232,256):
        print('\033[38;5;%im%i ' % (i,i),end='')
    print()

for i in range(40):
    for j in range(40):
        for k in range(255):
            print('\033[%0m', end='')
            print('\033[%i;%i;%imX'%(i,j,k),end='')
        print()
