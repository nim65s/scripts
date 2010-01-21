#!/bin/bash
# script à utiliser avec dl.sh.
# également basé sur plowshare, et donc sous license GNU GPL v3

ENMARCHE=`ps -ef | grep dl.sh | grep -v grep | wc -l`

if [ $ENMARCHE = 0]
  then
    $HOME/scripts/dl.sh $1
    shift
  fi

while [ $# -ne 0]
  do
    echo $1 >> $HOME/scripts/dl.txt
    shift
  done

exit 0
