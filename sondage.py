#!/usr/bin/env python3

choix = None

with open('sondage.txt', 'r') as f:
    for line in f:
        if line.startswith('* '):
            if choix is not None:
                print(section)
                for score, item in sorted(choix, reverse=True):
                    print(score, '\t', item)
            section = line.split()[1]
            choix = []
            continue
        if ':' in line:
            item, score = line.split(':')
            try:
                score = int(eval(score))
            except:
                score = 0
            choix.append((score, item))
