#!/usr/bin/env python

from pathlib import Path

from vcards import Vcard


def import_ab(filename):
    vcards = []
    started = False
    content = []
    with open(filename, 'r') as f:
        lines = f.read().replace('\n ', '').replace('\n\t', '').split('\n')

    for line in lines:
        ls = line.strip()
        if ls == 'BEGIN:VCARD':
            started = True
        elif ls == 'END:VCARD':
            started = False
            vcards.append(Vcard(filename.replace('.vcf', ''), content))
            content = []
        elif started:
            content.append(ls.split(':', 1))
    return vcards


def export_ab(vcards, filename):
    with open(filename, 'w') as f:
        print('BEGIN:VADDRESSBOOK', file=f)
        for vcard in vcards:
            print(vcard.fmt(), file=f)
        print('END:VADDRESSBOOK', file=f)


if __name__ == '__main__':
    for vcf in Path('.').glob('*.vcf'):
        vcards = import_ab(str(vcf))
        export_ab(vcards, vcf.stem + '_generated')
        print(f'diff -w {vcf} {vcf.stem}_generated')
