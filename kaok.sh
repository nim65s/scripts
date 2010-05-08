#!/bin/bash
cd $HOME/.config/awesome

if [[ $(ls | grep 12 | wc -l) -ge 1 ]]
  then
    I=1
    for FILE in $(ls 12* | sort -r)
      do
        if [[ $I = 1 ]]
          then
            I=2
            mv $FILE kaok.rc.lua
          else
            rm $FILE
          fi
      done
  fi
cp rc.lua /home/nim/dotfiles/rc.lua
if [[ -f rc.lua~ ]]
  then
    rm rc.lua~
  fi

exit
