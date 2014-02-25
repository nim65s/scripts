#!/bin/bash

cd

touch ~/.guignols_old

curl 'http://www.canalplus.fr/c-divertissement/pid1784-c-les-guignols.html' | grep 'c-les-guignols.html?vid=' | tr ' ' '\n' | grep '^href' | cut -d= -f2- | cut -d'>' -f1 | sort > ~/.guignols_new
diff ~/.guignols_old ~/.guignols_new | grep '<' | cut -d' ' -f2 > ~/.guignols_diff

while read l
do youtube-dl $l
done < ~/.guignols_diff

mv ~/.guignols_new ~/.guignols_old
rm ~/.guignols_diff
