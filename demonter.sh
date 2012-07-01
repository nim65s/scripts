#!/bin/bash

for i in $(mount|grep nim|cut -d" " -f 3)
do
    sudo umount $i
done

mount
