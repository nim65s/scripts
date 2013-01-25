#!/bin/bash

cd $HOME/images

[[ -e garfield.gif ]] && rm garfield.gif
wget -q "http://picayune.uclick.com/comics/ga/$(date '+%Y' --date 'yesterday')/ga$(date '+%y%m%d' --date 'yesterday').gif" -O garfield.gif
eog -f garfield.gif

exit 0
