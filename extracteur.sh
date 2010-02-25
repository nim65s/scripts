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

FICHIER=`mktemp`
for LIGNE in `cat $HOME/logs/nimscripts.log | grep -v 'Aucun fichier ou dossier de ce type'`
  do
    echo $LIGNE >> $FICHIER
  done
mv $FICHIER $HOME/logs/nimscripts.log

if [ `cat $HOME/logs/nimscripts.log | wc -l` != 0 ]
  then
    echo -e "\\033[1;31m""ERREURS dans $HOME/logs/nimscripts.log :""\\033[0;39m"
    cat $HOME/logs/nimscripts.log 
  fi

IFS=$OLDIFS

exit 0
