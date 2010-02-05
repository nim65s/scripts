#!/bin/bash

# Ce script est un daemon de téléchargement pour MegaUpload,
# basé sur plowshare, donc sous license
# GNU GPL v3
# Écrit par Nim65s.

if [ $# -ne 0 ]
	then
		while [ $# -ne 0 ]
			do
				echo $1 >> $HOME/scripts/dl.txt
				shift
			done
	else
		kate $HOME/scripts/dl.txt
	fi

if [ `ps -ef | grep plowdown | grep -v grep | wc -l` = 0 ]
	then
		while [ `cat $HOME/scripts/dl.txt | wc -l` != 0 ]
			do
				echo "TELECHARGEMENT DE `head $HOME/scripts/dl.txt -n 1`"
				FICHIER=`mktemp`
				plowdown -a $MUUA `head $HOME/scripts/dl.txt -n 1`
				sed '1d' $HOME/scripts/dl.txt >> $FICHIER
				mv $FICHIER $HOME/scripts/dl.txt
			done
	else
		echo "plowdown est en cours de fonctionnement => ajout des fichers dans la liste et fin du script."
	fi
exit 0
