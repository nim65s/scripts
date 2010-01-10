#!/bin/bash

IFS=$'\n'
adresseactuelle=$PWD
cd $HOME/images/wall/

nombreactuel=`ls | cut --delimiter="." -f 1 | sort -g | tail -n 1`
echo $nombreactuel

while [ $1 ]
	do
		let "nombreactuel += 1"
		cp $adresseactuelle/$1 $nombreactuel.$1
		echo $1 ajouté en tant que $PWD/$nombreactuel.$1
		shift
	done

cd $HOME/scripts
sed "s/nombre=[1-9]*/nombre=$nombreactuel/" wallpaper.sh > wallpaper2.sh
cat wallpaper2.sh > wallpaper.sh
rm wallpaper2.sh

exit 0
