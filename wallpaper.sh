#!/bin/bash

if [[ "$1" == "hostname" ]]
then
    if [[ -e "$HOME/images/hostname/`hostname`.jpg" ]]
    then
        awsetbg "$HOME/images/hostname/`hostname`.jpg"
    else
        awsetbg "$HOME/images/hostname/totoro_parapluie.jpg"
    fi
else
    export DISPLAY=:0.0
    awsetbg -r /home/nim/images/wallpaper/ -u feh
fi

exit
