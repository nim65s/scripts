#!/bin/bash

# option : "-r" => détruit l'archive
# option : "-d" => extrait l'archive dans un nouveau dossier

#TODO : si plus de 5 charactères sont similaires sur des fichiers différents => dans le meme dossier
#TODO : si il n'y a qu'un dossier dans l'archive => ne pas créer de dossier
#TODO : bug avec des parentheses, notamment dans un rar ?

OLDIFS=$IFS
IFS=$'\n'

declare -a EXTENSION
declare -a PROGRAMME

EXTENSION=( 0 zip rar tar tar.gz tar.bz2 7z )
PROGRAMME=( 0 unzip unrar tar tar tar 7z )
ARGUMENTS=( "" "" x -xvf -zxvf -jxvf e )

for((i=1;i<${#EXTENSION[*]};i++))
  do
    if [ -e *.${EXTENSION[$i]} ]
      then
	for FILE in `ls *.${EXTENSION[$i]} | sed "s/.${EXTENSION[$i]}//"`
	  do
	    if [[ "$1" == *d* ]]
	      then
		mkdir $FILE
		mv $FILE.${EXTENSION[$i]} $FILE/
		cd $FILE/
	      fi
	    ${PROGRAMME[$i]} ${ARGUMENTS[$i]} $FILE.${EXTENSION[$i]}
	    if [[ "$1" == *r* ]]
	      then
		rm $FILE.${EXTENSION[$i]}
	      fi
	    if [[ "$1" == *d* ]]
	      then
		cd ..
	      fi
	  done
      fi
  done

IFS=$OLDIFS

exit 0