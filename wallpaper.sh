#!/bin/bash

nombre=440
export DISPLAY=:0.1
pif=0
while [ $pif = 0 ]
    do
	pif=$RANDOM
	let "pif %= $nombre"
    done
awsetbg /home/nim/images/wall/$pif.*

exit
