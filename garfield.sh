#!/bin/bash

#TODO : merge du de la seconde boucle avec son test interne

export DISPLAY=:0.1
cd $HOME/images

if [[ -e ga$(date '+%y%m%d' --date '1 days ago').gif ]]
    then
	echo "image déjà vue"
    else
	wget "http://picayune.uclick.com/comics/ga/$(date '+%Y' --date '1 days ago')/ga$(date '+%y%m%d' --date '1 days ago').gif"
	feh -ZF ga$(date '+%y%m%d' --date '1 days ago').gif
    fi
for FILE in $(echo ga*.gif | grep -v ga\*.gif)
    do
	if [[ "$FILE" != "ga$(date '+%y%m%d' --date '1 days ago').gif" ]]
	    then
		rm $FILE
	    fi
    done
exit 0
