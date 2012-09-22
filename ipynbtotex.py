#!/usr/bin/python2
#-*- coding: utf-8 -*-

import re
import sys
import json

if len(sys.argv) < 2:
    sys.exit('Il me faut un fichier…')

f = ''
try:
    f = open(sys.argv[1], 'r')
except IOError:
    sys.exit('"%s" n’est pas un fichier valide' % sys.argv[1])

js = json.load(f)
f.close()

cells = js['worksheets'][0]['cells']

imgregex = re.compile(r"Image\('(\w+.png)'\)")

for cell in cells:
    if cell['cell_type'] == 'code':
        imgs = imgregex.findall(cell['input'])
        if imgs:
            for img in imgs:
                print '\includegraphics{img/%s}' % img
        else:
            lines = cell['input'].split('\n')
            print '\\begin{minted}[linenos]{python}'
            for line in lines:
                print line
            print '\end{minted}'
    elif cell['cell_type'] == 'markdown':
        lines = cell['source'].split('\n')
        for line in lines:
            print line
    elif cell['cell_type'] == 'heading':
        if cell['level'] == 1:
            print '\section{%s}' % cell['source']
        elif cell['level'] == 2:
            print '\subsection{%s}' % cell['source']
        elif cell['level'] == 3:
            print '\subsubsection{%s}' % cell['source']
    else:
        print 'FAAAAAAAAAAAAIL: type de la cellule non géré: %s' % cell['cell_type']

