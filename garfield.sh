#!/bin/bash

export DISPLAY=:0.1
cd $HOME/images

if [ ! -e ga`date '+%y%m%d' --date '1 days ago'`.gif ]
    then
	wget "http://picayune.uclick.com/comics/ga/`date '+%Y' --date '1 days ago'`/ga`date '+%y%m%d' --date '1 days ago'`.gif"
	feh ga`date '+%y%m%d' --date '1 days ago'`.gif
    fi
if [ -e ga`date '+%y%m%d' --date '2 days ago'`.gif ]
    then
	rm ga`date '+%y%m%d' --date '2 days ago'`.gif
    fi
exit 0
