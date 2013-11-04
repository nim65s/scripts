#!/bin/bash

if [[ -n $1 ]]
then lieu=$1
elif grep -q n7 /etc/resolv.conf
then lieu=net7
elif grep -q saurel /etc/resolv.conf
then lieu=home
else lieu=ailleurs
fi

echo post-up: $lieu

[[ $lieu == 'home' || $lieu == 'net7' || $lieu == 'ailleurs' ]] || exit 1

cd ~/.ssh
[[ -f config ]] && rm config
ln -s $lieu config

cd ~/.config/pulse
[[ -f client.conf ]] && rm client.conf
ln -s $lieu client.conf

[[ $lieu == 'home' ]] && DISPLAY=:0 synergyc ashitaka &
