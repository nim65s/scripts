#!/bin/bash

mkdir -p ~/guignols
cd ~/guignols
touch ~/.guignols

curl 'http://www.canalplus.fr/c-divertissement/pid1784-c-les-guignols.html' | grep 'c-les-guignols.html?vid=' | tr ' ' '\n' | grep '^href' | cut -d'"' -f2 | sort | uniq > new
diff ~/.guignols new | grep '>' | cut -d' ' -f2 > diff

while read url
do youtube-dl $url &
done < diff

wait

cat new ~/.guignols | sort | uniq > old
mv old ~/.guignols
rm new diff

rm -f "La semaine des Guignols - Semaine du "* 2> /dev/null
rm -f "Les Guignols du "* 2> /dev/null
