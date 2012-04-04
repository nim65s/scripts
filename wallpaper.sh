#!/bin/bash

if [[ "$1" == "hostname" ]]
then
    if [[ -e "$HOME/images/hostname/`hostname`.jpg" ]]
    then
        awsetbg "$HOME/images/hostname/`hostname`.jpg"
    elif [[ -e "$HOME/images/hostname/`hostname`.png" ]]
    then
        awsetbg "$HOME/images/hostname/`hostname`.png"
    else
        awsetbg "$HOME/images/hostname/ghibli.png"
    fi
else
    export DISPLAY=:0.0
    awsetbg -r $HOME/images/wallpaper -u feh
fi

exit
