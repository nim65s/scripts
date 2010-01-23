#!/bin/bash

nombre=443
export DISPLAY=:0.1
pif=0
pif=$RANDOM
let pif%=$nombre
let pif+=1
awsetbg /home/nim/images/wall/$pif.*

exit
