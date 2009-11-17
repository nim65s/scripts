#!/bin/bash

nombre=439
export DISPLAY=:0.1
pif=$RANDOM
let "pif %= $nombre"
awsetbg /home/nim/images/wall/$pif.*

exit
