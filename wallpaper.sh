#!/bin/bash

if [[ "$1" == "hostname" ]]
then
    cd $HOME/images/hostname || exit 1
    if [[ -e `hostname`.jpg ]]
    then awsetbg `hostname`.jpg
    elif [[ -e `hostname`.png ]]
    then awsetbg `hostname`.png
    else awsetbg ghibli.png
    fi
else
    awsetbg -r $HOME/images/wallpaper -u feh
fi

exit
