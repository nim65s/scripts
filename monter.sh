#!/bin/bash

prefix=/dev/sd$1
shift

mnt=/mnt/nim/
for i in $@
do
    if [[ ! -d $mnt$i ]] 
    then
        sudo mkdir -p $mnt$i
    fi
    sudo mount $prefix$i $mnt$i
done
