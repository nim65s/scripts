#!/bin/bash

nombreactuel=`ls /home/nim/images/wall/* | cut --delimiter="." -f 1 | cut --delimiter="/" -f 6 | sort -g | tail -n 1`

while [ $1 ]
	do
		let "nombreactuel += 1"
		cp $1 /home/nim/images/wall/$nombreactuel.$1
		echo $1 ajouté en tant que /home/nim/images/wall/$nombreactuel.$1
		shift
	done

cd /home/nim/scripts
sed "s/nombre=[1-9]*/nombre=$nombreactuel/" wallpaper.sh > wallpaper2.sh
cat wallpaper2.sh > wallpaper.sh
rm wallpaper2.sh

exit


