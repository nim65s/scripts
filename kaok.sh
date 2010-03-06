#!/bin/bash
cd $HOME/.config/awesome

NB=`ls 12* 2>> $HOME/logs/nimscritps.log | wc -l`
I=1
if [ $NB != 0 ]
 then
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

$HOME/scripts/nimscriptslog.sh

exit
