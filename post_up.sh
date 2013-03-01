#!/bin/bash

[[ $1 == 'home' || $1 == 'net7' || $1 == 'ailleurs' ]] || exit 1

cd ~/.ssh
[[ -f config ]] && rm config
ln -s $1 config

cd ~/.config/pulse
[[ -f client.conf ]] && rm client.conf
ln -s $1 client.conf

sleep 10
DISPLAY=:0 ssh-add

if [[ $1 == 'home' ]]
then
    cd
    [[ -f .synergy.conf ]] && rm .synergy.conf
    ln -s .synergy.conf.$1 .synergy.conf
    DISPLAY=:0 synergys
fi

