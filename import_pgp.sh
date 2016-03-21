#!/bin/bash

a=${1:-$(mktemp)}
b=$(mktemp)

vim $a
sed -n '/-----BEGIN PGP MESSAGE-----/,/-----END PGP MESSAGE-----/p' $a > $b
gpg --decrypt $b > $a
sed -n '/-----BEGIN PGP PUBLIC KEY BLOCK-----/,/-----END PGP PUBLIC KEY BLOCK-----/p' $a > $b
gpg --import $b
rm $a $b
