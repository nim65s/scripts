#!/bin/bash

[[ $1 == 'home' || $1 == 'net7' || $1 == 'ailleurs' ]] || exit 1

cd ~/.ssh
[[ -f config ]] && rm config
ln -s $1 config

cd ~/.config/pulse
[[ -f client.conf ]] && rm client.conf
ln -s $1 client.conf

if [[ $1 == 'home' ]]
then
    DISPLAY=:0 synergyc ashitaka
fi
