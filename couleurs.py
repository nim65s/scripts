#!/usr/bin/python
#-*- coding: utf-8 -*-

"""module pour colorer la sortie des consoles et apprendre à écrire des modules \o/"""

def rouge(texte):
    """printe un «texte» en rouge gras"""
    print('\033[1;31m%s\033[0m' % texte)

def vert(texte):
    """printe un «texte» en vert gras"""
    print('\033[1;32m%s\033[0m' % texte)

def jaune(texte):
    """printe un «texte» en vert gras"""
    print('\033[1;33m%s\033[0m' % texte)

def style(texte, style):
    """printe un «texte» formaté selon le «style»"""
    print('\033[%sm%s\033[0m' % (style,texte))

def colore_256(texte, couleur):
    """printe un «texte» coloré selon la «couleur»"""
    print('\033[38;5;%sm%s\033[0m' % (couleur,texte))

def exemple():
    """Affiche un tas de couleurs"""
    style = [0,1,3,4]
    for a in range(8):
        for i in range(30,38):
            if a == 0:
                print('\033[%im  \\033[%im\033[0m '%(i,i),end='')
            else:
                print('\033[%i;%im\\033[%i;%im\033[0m '%(a,i,a,i),end='')
            for j in range(40,48):
                if a == 0:
                    print('\033[%i;%im  \\033[%i;%im\033[0m '%(i,j,i,j),end='')
                else:
                    print('\033[%i;%i;%im\\033[%i;%i;%im\033[0m '%(a,i,j,a,i,j),end='')
            print()
        print()
    print()

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

if __name__ == '__main__':
    exemple()
