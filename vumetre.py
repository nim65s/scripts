#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# arecord -f S16_LE  -t raw -r 16000 | ./vumetre.py

import sys,struct,os,pygame,threading,time
from collections import deque


BLACK = (0, 0, 0)
WHITE = (255, 255, 255)
RED = (255, 0, 0)
GREEN = (0, 255, 0)
BLUE = (0, 0, 255)

WINDOWWIDTH = 1024
WINDOWHEIGHT = 768

def uiLoop(datas):
    pygame.display.init()
    pygame.font.init()
    windowSurface = pygame.display.set_mode((WINDOWWIDTH,WINDOWHEIGHT),0,32)
    pygame.display.set_caption('Vumètre')
    pygame.mouse.set_visible(0)
    background_file_name = os.path.join(".","kdeg.png")
    background = pygame.image.load(background_file_name).convert()
    font = pygame.font.Font(None, 30)

    maximum = datas.moyenne
    lent = datas.moyenne

    while True:
        # Update data & moy
        if datas.moyenne > maximum:
            maximum = datas.moyenne

        if datas.moyenne > lent:
            lent = datas.moyenne
        else:
            lent -= 100

        for event in pygame.event.get():
            if event.type == 2 and event.key == 27:
     	        pygame.quit()
                return
            if event.type == 2 and event.key == 'r':
                maximum = 0

        text = font.render(str(datas.moyenne),1,BLACK,GREEN)
        text2 = font.render(str(maximum),1,BLACK,RED)
        text3 = font.render(str(lent),1,BLACK,BLUE)
        text4 = font.render(str(datas.val),1,BLACK,WHITE)
        textpos = text.get_rect()
        textpos2 = text2.get_rect()
        textpos3 = text3.get_rect()
        textpos4 = text4.get_rect()
        textpos.centerx = background.get_rect().centerx
        textpos2.centerx = background.get_rect().centerx
        textpos2.centery = background.get_rect().centery
        textpos3.centery = background.get_rect().centery
        background.blit(text,textpos)
        background.blit(text2,textpos2)
        background.blit(text3,textpos3)
        background.blit(text4,textpos4)
        windowSurface.blit(background,(0,0))
        background = pygame.image.load(background_file_name).convert()
        pygame.draw.line(windowSurface, WHITE, (94,514),(372,514))
        pygame.draw.line(windowSurface, GREEN, (84,395),(385,395))
        pygame.draw.line(windowSurface, RED, (69,222),(402,222))
        pygame.draw.rect(windowSurface, WHITE, (56,0,362,727-datas.moyenne/50))
        pygame.draw.line(windowSurface, RED, (50,727-maximum/50),(400, 727-maximum/50))
        pygame.draw.line(windowSurface, BLACK, (231, 727-datas.val/50),(231,727))
        pygame.draw.line(windowSurface, BLUE, (50, 727-lent/50), (400, 727-lent/50))

        pygame.display.flip()
        time.sleep(0.2)


class DataMgr(threading.Thread):
    def __init__(self):
        super(DataMgr,self).__init__()
        self.daemon = True
        self.moyenne = 0
        self.continueRunning = True
        self.val = 0

    def run(self):
        liste = deque()
        buff = 50
        count = 0
        somme = 0
        while self.continueRunning:
            self.val = abs(struct.unpack('<h',sys.stdin.read(2))[0])
            liste.append(self.val)
  
            somme += self.val
            count += 1
            if count > buff:
                somme -= liste.popleft()
            self.moyenne = somme / buff


data = DataMgr()
data.start()

uiLoop(data)

data.continueRunning = False
data.join()
