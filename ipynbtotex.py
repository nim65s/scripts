#!/usr/bin/python2
#-*- coding: utf-8 -*-

import re
import sys
import json
import codecs

if len(sys.argv) < 2:
    sys.exit('Il me faut un fichier…')
elif len(sys.argv) < 3:
    sys.exit('Il me faut un numéro…')

f = ''
try:
    f = open(sys.argv[1], 'r')
except IOError:
    sys.exit('"%s" n’est pas un fichier valide' % sys.argv[1])

js = json.load(f)
f.close()

f = codecs.open('tex/%s-genere.tex' % sys.argv[2], encoding='utf-8', mode='w')

cells = js['worksheets'][0]['cells']

imgregex = re.compile(r"Image\('(\w+.png)'\)")

for cell in cells:
    if cell['cell_type'] == 'code':
        imgs = imgregex.findall(cell['input'])
        if imgs:
            for img in imgs:
                f.write('\n\\includegraphics[width=\linewidth]{../img/%s}\n\n' % img)
        else:
            f.write('\\begin{minted}[linenos]{python}\n')
            f.write(cell['input'] + '\n')
            f.write('\\end{minted}\n')
            if cell['outputs'] and cell['outputs'][0]['output_type'] == 'stream':
                f.write('\\begin{verbatim}\n')
                f.write(cell['outputs'][0]['text'])
                f.write('\\end{verbatim}\n')
    elif cell['cell_type'] == 'markdown':
        f.write('\n' + cell['source'] + '\n')
    elif cell['cell_type'] == 'heading':
        if cell['level'] == 1:
            f.write('\\section{%s}\n' % cell['source'])
        elif cell['level'] == 2:
            f.write('\\subsection{%s}\n' % cell['source'])
        elif cell['level'] == 3:
            f.write('\\subsubsection{%s}\n' % cell['source'])
    else:
        print 'FAAAAAAAAAAAAIL: type de la cellule non géré: %s' % cell['cell_type']
f.close()
