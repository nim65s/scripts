#!/bin/bash

nombre=331
export DISPLAY=:0.1
pif=0
pif=$RANDOM
let pif%=$nombre
let pif+=1
awsetbg /home/nim/images/wall/$pif.*

exit
