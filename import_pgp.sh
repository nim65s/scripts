#!/bin/bash

a=$(mktemp)
b=$(mktemp)

vim $a
gpg --decrypt $a > $b
sed -n '/-----BEGIN PGP PUBLIC KEY BLOCK-----/,/-----END PGP PUBLIC KEY BLOCK-----/p' $b > $a
gpg --import $a
rm $a $b
