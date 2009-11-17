#!/bin/bash

cd /home/nim/images/

#if [ -e ga`date '+%y%m%d' --date '1 days ago'`.gif ]
#then
#else
wget "http://picayune.uclick.com/comics/ga/`date '+%Y' --date '1 days ago'`/ga`date '+%y%m%d' --date '1 days ago'`.gif"
convert ga`date '+%y%m%d' --date '1 days ago'`.gif garfield.png
#fi
exit
