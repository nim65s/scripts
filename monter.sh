#!/bin/bash

prefix=/dev/sd$1
shift

cd /mnt/nim
for i in $@
do
    if [[ ! -d $i ]] 
    then
        sudo mkdir $i
    fi
    sudo mount ${prefix}$i $i
done
