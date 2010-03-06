#!/bin/bash

# option : "-r" => détruit l'archive

#TODO : bug avec des parentheses, notamment dans un rar ?

ODLIFS=$IFS
IFS=$'\n'

declare -a EXTENSION
declare -a PROGRAMME
declare -a ARGUMENTS
EXTENSION=( 0 zip rar tar tgz tar.gz tar.bz2 7z )
PROGRAMME=( 0 unzip unrar tar tar tar tar 7z )
ARGUMENTS=( "" "" x -xvf -zxvf -zxvf -jxvf e )

mkdir NIMEWF
for((i=1;i<${#EXTENSION[*]};i++))
  do
    for FILE in `ls *.${EXTENSION[$i]} 2>> $HOME/logs/nimscripts.log | sed "s/.${EXTENSION[$i]}//"`
      do
	mkdir $FILE
	mv $FILE.${EXTENSION[$i]} $FILE/
	cd $FILE/
	${PROGRAMME[$i]} ${ARGUMENTS[$i]} "$FILE.${EXTENSION[$i]}"
	NB=2
	if [[ "$1" == *r* ]]
	  then
	    rm $FILE.${EXTENSION[$i]}
	    NB=1
	  fi
	if [[ `ls | wc -l` == $NB ]]
	  then
	    mv * ../NIMEWF
	    cd ..
	    rmdir $FILE/
	  else
	    cd ..
	  fi
    done
done

mv NIMEWF/* . 2>> $HOME/logs/nimscripts.log
rmdir NIMEWF

$HOME/scripts/nimscriptslog.sh
IFS=$OLDIFS

exit 0
