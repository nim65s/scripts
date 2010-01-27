#!/bin/bash

# option : "-r" => détruit l'archive
# option : "-d" => extrait l'archive dans un nouveau dossier

#TODO : si plus de 5 charactères sont similaires sur des fichiers différents => dans le meme dossier
#TODO : si il n'y a qu'un dossier dans l'archive => ne pas créer de dossier
#TODO : bug avec des parentheses, notamment dans un rar ?

ODLIFS=$IFS
IFS=$'\n'

declare -a EXTENSION
declare -a PROGRAMME
declare -a ARGUMENTS
EXTENSION=( 0 zip rar tar tar.gz tar.bz2 7z )
PROGRAMME=( 0 unzip unrar tar tar tar 7z )
ARGUMENTS=( "" "" x -xvf -zxvf -jxvf e )

for((i=1;i<${#EXTENSION[*]};i++))
  do
    for FILE in `ls *.${EXTENSION[$i]} 2>> $HOME/logs/extracteur.log | sed "s/.${EXTENSION[$i]}//"`
      do
	echo $FILE
	if [[ "$1" == *d* ]]
	  then
	    mkdir $FILE
	    mv $FILE.${EXTENSION[$i]} $FILE/
	    cd $FILE/
	  fi
	${PROGRAMME[$i]} ${ARGUMENTS[$i]} "$FILE.${EXTENSION[$i]}"
	if [[ "$1" == *r* ]]
	  then
	    rm $FILE.${EXTENSION[$i]}
	  fi
	if [[ "$1" == *d* ]]
	  then
	    cd ..
	  fi
    done
done

FICHIER=`mktemp`
for LIGNE in `cat $HOME/logs/extracteur.log | grep -v 'Aucun fichier ou dossier de ce type'`
  do
    echo $LIGNE >> $FICHIER
  done
mv $FICHIER $HOME/logs/extracteur.log

if [ `cat $HOME/logs/extracteur.log | wc -l` != 0 ]
  then
    echo -e "\\033[1;31m""ERREURS dans $HOME/logs/extracteur.log :""\\033[0;39m"
    cat $HOME/logs/extracteur.log 
  fi

IFS=$OLDIFS

exit 0
