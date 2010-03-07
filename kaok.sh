#!/bin/bash
cd $HOME/.config/awesome

if [ -e 12* ]
  then
    NB=`ls 12* | wc -l`
    I=1
    for FILE in `ls 12* | sort -r`
      do
        if [ $I = 1 ]
          then
            I=2
            mv $FILE kaok.rc.lua
          else
            rm $FILE
          fi
      done
  fi
cp rc.lua /home/nim/dotfiles/rc.lua

exit
