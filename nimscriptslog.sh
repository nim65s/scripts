#!/bin/bash

FICHIER=`mktemp`
for LIGNE in `cat $HOME/logs/nimscripts.log | grep -v 'Aucun fichier ou dossier de ce type'`
  do
    echo "[`date +'%d/%m - %T'`]  $LIGNE" >> $FICHIER
  done
mv $FICHIER $HOME/logs/nimscripts.log

if [ `cat $HOME/logs/nimscripts.log | wc -l` != 0 ]
  then
    echo -e "\\033[1;31m""ERREURS dans $HOME/logs/nimscripts.log :""\\033[0;39m"
    cat $HOME/logs/nimscripts.log
  fi

exit 0
