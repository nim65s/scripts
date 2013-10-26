#!/bin/bash

which optipng || exit 1
which jpegoptim || exit 2

for i in $(find . -iname \*.png)
do
    optipng "$i"
done

for i in $(find . -iname \*.jpg)
do
    jpegoptim --strip-all "$i"
done
