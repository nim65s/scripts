#!/usr/bin/env python

from argparse import ArgumentParser
from datetime import date
from subprocess import run

parser = ArgumentParser(description='arrange a graphviz from gramps by year')
parser.add_argument('infile', default='in.gv', nargs='?', help='input filename')
parser.add_argument('outfile', default='out.gv', nargs='?', help='output filename')
parser.add_argument('-y', '--start_year', type=int, nargs='?', default=1867, help='oldest year of the graph')


def add_timeline(infile, outfile, start_year):
    years_added = False
    with open(outfile, 'w') as of:
        with open(infile) as f:
            for line in f:
                line = line.strip('\r\n')
                if not years_added and line.strip() == '':
                    print('', file=of)
                    print('{', file=of)
                    print('node [shape=none, color=white, fillcolor=white, fontsize=20];', file=of)
                    for year in range(start_year, date.today().year + 1):
                        print(f'{year} -> {year + 1} [style=invis];', file=of)
                    print('}', file=of)
                    years_added = True
                if '"I' in line and 'label="' in line and '\\n' in line:  # such regex…
                    try:
                        year = int(line.split('(')[1].split('-')[0].split(' ')[0])
                        if year < start_year:
                            print(f'{year} is older than start_year !')
                        print('  { rank=same; %i; %s }' % (year, line), file=of)
                    except:
                        print("can't find birthdate here:", line)
                print(line, file=of)
    run(['dot', '-Tsvg', '-o', f'{outfile}.svg', outfile])


if __name__ == '__main__':
    add_timeline(**vars(parser.parse_args()))
