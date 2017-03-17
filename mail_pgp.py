#!/usr/bin/env python

from os import walk
from os.path import expanduser, join
from subprocess import PIPE, run

from chardet.universaldetector import UniversalDetector
from tqdm import tqdm

mails = expanduser('~/.mails')

fail = 0
nothing = 0
knew = 0
new = 0
other = 0
quoted = 0

detector = UniversalDetector()


for root, _, filenames in tqdm(walk(mails), total=len(list(walk(mails)))):
    if filenames and 'notmuch' not in root:
        for filename in tqdm(filenames, desc=root[len(mails) + 1:], leave=False):
            fn = join(root, filename)
            try:
                with open(fn) as f:
                    decrypt = '-----BEGIN PGP MESSAGE-----' in f.read()
            except:
                try:
                    detector.reset()
                    with open(fn, 'rb') as f:
                        for line in f:
                            detector.feed(line)
                            if detector.done:
                                break
                    detector.close()
                    with open(fn, encoding=detector.result['encoding']) as f:
                        decrypt = '-----BEGIN PGP MESSAGE-----' in f.read()
                except:
                    fail += 1
                    print('FAIL', fn)
                    continue
            if decrypt:
                dec = run(['gpg', '--decrypt', fn], stdout=PIPE, stderr=PIPE)
                ret = run(['gpg', '--import'], input=dec.stdout, stderr=PIPE)
            else:
                ret = run(['gpg', '--import', fn], stderr=PIPE)
            if b'aucune donn' in ret.stderr:
                nothing += 1
            elif b'non modifi' in ret.stderr:
                knew += 1
            elif b'Quoted-Printable' in ret.stderr:
                quoted += 1
            elif b'nouvelles signatures' in ret.stderr:
                new += 1
            else:
                other += 1
                print(ret.stderr)

print()
print(fail, 'mail processing failed')
print(nothing, 'mail with no GPG data')
print(knew, 'mail with not modified keys')
print(new, 'mail with new keys/signatures')
print(other, 'other')
