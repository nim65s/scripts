#!/bin/bash

which optipng || exit 1
which jpegoptim || exit 2

for d in /var/www/*/{media,static}
do
    for i in $(find $d -iname \*.png)
    do
        optipng "$i"
        chown www-data:www-data "$i"
    done

    for i in $(find $d -iname \*.jpg)
    do
        jpegoptim --strip-all "$i"
        chown www-data:www-data "$i"
    done
done
