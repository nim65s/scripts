#!/bin/bash

# Ce script est un daemon de téléchargement pour MegaUpload,
# basé sur plowshare, donc sous license
# GNU GPL v3
# Écrit par Nim65s.

if [ $# -ne 0 ]
	then
		if [ -d $1 ]
			then
				cd $1
				shift
			else
				if [ ! -d $HOME/Téléchargements ]
					then
						mkdir $HOME/Téléchargements
					fi
				cd $HOME/Téléchargements
			fi
		while [ $# -ne 0 ]
			do
				echo $1 >> $HOME/scripts/dl.txt
				shift
			done
	else
		if [[ "`pidof -s -x -o %PPID /usr/share/apps/kate`" = "" ]]
			then
				kate $HOME/scripts/dl.txt
			else
				nano $HOME/scripts/dl.txt
			fi
	fi

if [[ "`pidof -s -x -o %PPID plowdown`" = "" ]]
	then
		while [ `cat $HOME/scripts/dl.txt | wc -l` != 0 ]
			do
				todl=$(head $HOME/scripts/dl.txt -n 1 | cut --delimiter="=" -f 2)
				echo "TELECHARGEMENT DE http://www.megaupload.com/?d=$todl DANS $PWD"
				plowdown -a $MUUA http://www.megaupload.com/?d=$todl || echo " !!!!!!!!! PLOWDOWN erreur # $? !!!!!!!!!!!!! "
				sed -i "/$todl/d" $HOME/scripts/dl.txt
			done
		rm $HOME/scripts/dl.txt
	else
		echo "plowdown est en cours de fonctionnement => ajout des fichers dans la liste et fin du script."
		exit 1
	fi
exit 0
