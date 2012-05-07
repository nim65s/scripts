#!/bin/bash

cd $HOME/images

[[ -e garfield.gif ]] && rm garfield.gif
wget -nv "http://picayune.uclick.com/comics/ga/$(date '+%Y' --date 'yesterday')/ga$(date '+%y%m%d' --date 'yesterday').gif" -O garfield.gif
feh -ZF garfield.gif

exit 0
