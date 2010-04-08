#!/bin/bash

# Ce script est un daemon de téléchargement pour MegaUpload,
# basé sur plowshare, donc sous license
# GNU GPL v3
# Écrit par Nim65s.

# bugreport : 
#             soucis si la première ligne n'est pas correcte |||| HEIN ? oO

if [[ $# -ne 0 ]]
  then
    if [[ -d $1 ]]
      then
	cd $1
	shift
      else
	mkdir -pv $HOME/Téléchargements
	cd $HOME/Téléchargements
      fi
    while [[ $# -ne 0 ]]
      do
	echo $1 >> $HOME/scripts/dl.txt
	shift
      done
  else
    [[ "$(pidof -s -x -o %PPID /usr/share/apps/kate)" = "" ]] && kate $HOME/scripts/dl.txt || nano $HOME/scripts/dl.txt
  fi

if [[ "$(pidof -s -x -o %PPID plowdown)" = "" ]]
  then
    while [[ $(cat $HOME/scripts/dl.txt | wc -l) != 0 ]]
      do
	todl=$(head $HOME/scripts/dl.txt -n 1 | cut --delimiter="=" -f 2)
	echo -e "\n\n\033[1mTéléchargement de http://www.megaupload.com/?d=$todl ===> $PWD\n\033[0m"
	plowdown -a $MUUA http://www.megaupload.com/?d=$todl || echo " !!!!!!!!! PLOWDOWN erreur # $? !!!!!!!!!!!!! "
	sed -i "/$todl/d" $HOME/scripts/dl.txt # sed "/$(echo $todl | sed -i "s/[/]/\\\\\//g")/d" $HOME/scripts/dl.txt
      done
    rm $HOME/scripts/dl.txt
  else
    echo "plowdown est en cours de fonctionnement => ajout des fichers dans la liste et fin du script."
    exit 1
  fi

echo "fin de dl.sh"
exit 0
