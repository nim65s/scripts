#!/bin/bash

#option -m : déplace l'image plutôt que de la copier

OLDIFS=$IFS
IFS=$'\n'
adresseactuelle=$PWD
cd $HOME/images/wall/

nombreactuel=`ls | cut --delimiter="." -f 1 | sort -g | tail -n 1`
echo $nombreactuel

while [ $1 ]
	do
		let "nombreactuel += 1"
		if [[ "$1" == *m* ]]
			then
				mv $adresseactuelle/$1 $nombreactuel.$1
			else
				cp $adresseactuelle/$1 $nombreactuel.$1
			fi
		echo $1 ajouté en tant que $PWD/$nombreactuel.$1
		shift
	done

cd $HOME/scripts
sed "s/nombre=[0-9]*/nombre=$nombreactuel/" wallpaper.sh > wallpaper2.sh
cat wallpaper2.sh > wallpaper.sh
rm wallpaper2.sh
IFS=$OLDIFS

exit 0
