#!/bin/bash

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
			h | -h )
				echo "usage : makewallpaper [ fichiers ] [ -m ] fichiers"
				echo "        copie les fichiers dans le répertoire $HOME/images/wall en leur attribuant un numero"
				echo "        puis met à jour le script wallpaper.sh avec le nouveau nombre de fonds d'écran"
				echo "        les fichiers mentionnés après l'option -m seront déplacés plutôt que copiés"
				echo "        les fichiers mentionnés après l'option -c seront à nouveau copiés plutôt que déplacés"
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
sed "s/nombre=[0-9]*/nombre=$nombreactuel/" wallpaper.sh > wallpaper2.sh
cat wallpaper2.sh > wallpaper.sh
rm wallpaper2.sh
IFS=$OLDIFS

exit 0
