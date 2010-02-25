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

FICHIER=`mktemp`
for LIGNE in `cat $HOME/logs/nimscripts.log | grep -v 'Aucun fichier ou dossier de ce type'`
  do
    echo $LIGNE >> $FICHIER
  done
mv $FICHIER $HOME/logs/nimscripts.log

if [ `cat $HOME/logs/nimscripts.log | wc -l` != 0 ]
  then
    echo -e "\\033[1;31m""ERREURS dans $HOME/logs/nimscripts.log :""\\033[0;39m"
    cat $HOME/logs/nimscripts.log
  fi

exit
