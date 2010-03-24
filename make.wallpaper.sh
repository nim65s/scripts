#!/bin/bash

# Script de gestion d'une "base de données" de fond d'écrans.
# Utilise findup de fslint, Copyright 2000-2009 by Padraig Brady <P@draigBrady.com>,
# donc sous licence GNU GPL v3.
# Écrit par Nim65s.

OLDIFS=$IFS
IFS=$'\n'
adresseactuelle=$PWD
cd $HOME/images/wall/
ACTION="cp"
nombreactuel=`ls | cut --delimiter="." -f 1 | sort -g | tail -n 1`
echo "makewallpaper : $nombreactuel fonds d'écran déjà présents"

while [ $1 ]
	do
		case $1 in
			m | -m )
				ACTION="mv"
				shift
				;;
			c | -c )
				ACTION="cp"
				shift
				;;
			d | -d )
#TODO : bug si ${#ORPHANS[*]} > nombre de fichiers à déplacer.
				/usr/share/fslint/fslint/findup -d
				declare -a ORPHANS
				for((i=1;i<=$nombreactuel;i++))
					do
						if [ `ls | grep ^$i[.] | wc -l` == 0 ]
							then
								ORPHANS=( ${ORPHANS[*]} $i )
							fi
					done
				echo "Il y a actuellement ${#ORPHANS[*]} orphelins"
				let "nombreactuel -= ${#ORPHANS[*]}"
				for((i=0;i<${#ORPHANS[*]};i++))
					do
						if [ `ls | sort -g | tail -n 1 | cut --delimiter="." -f 1 ` -gt ${ORPHANS[$i]} ]
							then
								mv -v `ls | sort -g | tail -n 1` ${ORPHANS[$i]}.`ls | sort -g | tail -n 1 | cut --delimiter="." -f 2-`
							fi
					done
				shift
				;;
			h | -h )
				echo "usage : makewallpaper [ fichiers ] [ -m  fichiers [ -c ]] fichiers"
				echo "          copie les fichiers dans le répertoire $HOME/images/wall en leur attribuant un numero"
				echo "          puis met à jour le script wallpaper.sh avec le nouveau nombre de fonds d'écran"
				echo "          les fichiers mentionnés après l'option -m seront déplacés plutôt que copiés"
				echo "          les fichiers mentionnés après l'option -c seront à nouveau copiés plutôt que déplacés"
				echo "        makewallpaper -d"
				echo "          supprime les doublons et met l'index à jour"
				echo "        makewallpaper -h"
				echo "          affiche cette aide"
				IFS=$OLDIFS
				exit 0
				;;
			*)
				let "nombreactuel += 1"
				$ACTION -v $adresseactuelle/$1 $nombreactuel.$1
				shift
				;;
			esac
	done

cd $HOME/scripts
echo "nombre=$nombreactuel > wallpaper.sh"
FICHIER=`mktemp
sed "s/nombre=[0-9]*/nombre=$nombreactuel/" wallpaper.sh > $FICHIER
mv $FICHIER wallpaper.sh
IFS=$OLDIFS

exit 0
