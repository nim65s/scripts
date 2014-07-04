#!/bin/bash

which optipng || exit 1
which jpegoptim || exit 2
test -f ~/.croptimg || exit 3

while read d
do
    for i in $(find . -iname \*.png)
    do
        optipng "$i"
    done

    for i in $(find . -iname \*.jpg)
    do
        jpegoptim --strip-all "$i"
    done
done < ~/.croptimg
