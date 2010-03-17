#!/bin/bash

# option : "-r" => détruit l'archive

#TODO : bug avec des parentheses, notamment dans un rar ? => fonction d'echappement des caractères spéciaux ?

ODLIFS=$IFS
IFS=$'\n'

declare -a EXTENSION
declare -a PROGRAMME
declare -a ARGUMENTS
EXTENSION=( zip rar tar tgz tar.gz tar.bz2 7z )
PROGRAMME=( unzip unrar tar tar tar tar 7z )
ARGUMENTS=( "" x -xvf -zxvf -zxvf -jxvf e )

mkdir NIMEWF
for((i=0;i<${#EXTENSION[*]};i++))
  do
    if [ `ls | grep .${EXTENSION[$i]}$ | wc -l` -ge 1 ]
      then
        for FILE in `ls *.${EXTENSION[$i]} | sed "s/.${EXTENSION[$i]}//"`
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
      fi
done

if [ `ls -A NIMEWF/ | wc -l` -ge 1 ]
  then
    mv NIMEWF/* .
  fi
rmdir NIMEWF

IFS=$OLDIFS

exit 0
