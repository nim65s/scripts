#!/bin/bash

[[ -x /usr/local/bin/nitrogen ]] || (echo "need git://github.com/l3ib/nitrogen.git" && exit 1)

cd ~/images/wallpaper
/usr/local/bin/nitrogen --head=0 --set-zoom-fill $(ls|shuf -n1)
