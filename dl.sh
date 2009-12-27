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
		nano $HOME/scripts/dl.txt
	fi

while [ `cat $HOME/scripts/dl.txt | wc -l` != 0 ]
	do
		FICHIER=`mktemp`
		plowdown -a $MUUA `head $HOME/scripts/dl.txt -n 1` || exit 1
		sed '1d' $HOME/scripts/dl.txt >> $FICHIER
		mv $FICHIER $HOME/scripts/dl.txt
	done
exit 0
