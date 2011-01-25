#!/usr/bin/env python2
# -*- coding: utf-8 -*-

import sys,struct,os,pygame
from collections import deque

#print('arecord -f S16_LE  -t raw -r 16000 | ./vumetre.py')

liste = deque()
buff = 50
count = 0
somme = 0
maximum = 0

BLACK = (0, 0, 0)
WHITE = (255, 255, 255)
RED = (255, 0, 0)
GREEN = (0, 255, 0)
BLUE = (0, 0, 255)

WINDOWWIDTH = 1920
WINDOWHEIGHT = 1080

pygame.init()
windowSurface = pygame.display.set_mode((WINDOWWIDTH,WINDOWHEIGHT),0,32)
pygame.display.set_caption('Vumètre')
pygame.mouse.set_visible(0)
background = pygame.Surface(windowSurface.get_size()).convert()
background.fill(WHITE)
font = pygame.font.Font(None, 30)

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

    for event in pygame.event.get():
        if event.type == 2 and event.key == 27:
            pygame.quit()
            sys.exit(0)

    text = font.render(str(moyenne),1,BLACK,GREEN)
    text2 = font.render(str(maximum),1,BLACK,RED)
    textpos = text.get_rect()
    textpos2 = text2.get_rect()
    textpos2.centery = background.get_rect().centery
    background.fill(WHITE)
    background.blit(text,textpos)
    background.blit(text2,textpos2)
    windowSurface.blit(background,(0,0))
    pygame.draw.rect(windowSurface,GREEN,(0,30,moyenne*WINDOWWIDTH/32684,20))
    pygame.draw.rect(windowSurface,BLUE,(0,50,maximum*WINDOWWIDTH/32684,20))
    pygame.display.update()
