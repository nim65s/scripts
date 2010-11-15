#!/bin/bash

export DISPLAY=:0.0
cd $HOME/images

if [[ -e ga$(date '+%y%m%d' --date '1 days ago').gif ]]
  then
    echo "image déjà vue"
  else
    wget -nv "http://picayune.uclick.com/comics/ga/$(date '+%Y' --date '1 days ago')/ga$(date '+%y%m%d' --date '1 days ago').gif"
    feh -ZF ga$(date '+%y%m%d' --date '1 days ago').gif
  fi
for FILE in $(echo ga*.gif | sed "s/ /\n/g" | grep -v "ga\*.gif\|$(date '+%y%m%d' --date '1 days ago')")
  do
    rm $FILE
  done
exit 0
