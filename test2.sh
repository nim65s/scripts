#!/bin/bash

nombreactuel=987
cd /home/nim/scripts
sed "s/nombre=[1-9]*/nombre=$nombreactuel/" wallpaper.sh > wallpaper2.sh
cat wallpaper2.sh > wallpaper.sh
rm wallpaper2.sh

exit

