#!/bin/bash

# Script de gestion de files d'attentes et de miroriii
# Fondé sur plowshare
# Écrit par Nim65s
# Licence GNU GPL v3

# options : 
#           o : overpasser le verrou TODO
# codes de sortie : 
#                   1 : pas d'arguments 
#                   2 : déjà en fonctionnement => ajout des adresses dans la liste d'attente

# variables issues de plowshare v 0.9.1
declare -a MODULES
MODULES=(rapidshare megaupload 2shared badongo mediafire 4shared zshare depositfiles storage_to uploaded_to uploading netload_in usershare sendspace x7_to hotfile divshare freakshare dl_free_fr loadfiles)
MODULE_2SHARED_REGEXP_URL="http://\(www\.\)\?2shared.com/file/"
MODULE_4SHARED_REGEXP_URL="http://\(www\.\)\?4shared\.com/file/"
MODULE_BADONGO_REGEXP_URL="http://\(www\.\)\?badongo.com/"
MODULE_DEPOSITFILES_REGEXP_URL="http://\(\w\+\.\)\?depositfiles.com/"
MODULE_DIVSHARE_REGEXP_URL="http://\(www\.\)\?divshare.com/download"
MODULE_DL_FREE_FR_REGEXP_URL="http://dl.free.fr/"
MODULE_FREAKSHARE_REGEXP_URL="^http://\(www\.\)\?freakshare\.net/files/"
MODULE_HOTFILE_REGEXP_URL="^http://\(www\.\)\?hotfile\.com/"
MODULE_LETITBIT_REGEXP_URL="http://\(www\.\)\?letitbit.net/"
MODULE_LOADFILES_REGEXP_URL="http://\(\w\+\.\)\?loadfiles\.in/"
MODULE_MEDIAFIRE_REGEXP_URL="http://\(www\.\)\?mediafire.com/"
MODULE_MEGAUPLOAD_REGEXP_URL="^http://\(www\.\)\?mega\(upload\|rotic\|porn\).com/"
MODULE_NETLOAD_IN_REGEXP_URL="^http://\(www\.\)\?netload\.in/"
MODULE_RAPIDSHARE_REGEXP_URL="http://\(\w\+\.\)\?rapidshare.com/"
MODULE_SENDSPACE_REGEXP_URL="http://\(www\.\)\?sendspace.com/file/"
MODULE_STORAGE_TO_REGEXP_URL="^http://\(www\.\)\?storage.to/get/"
MODULE_UPLOADED_TO_REGEXP_URL="^http://\(www\.\)\?\(uploaded.to\|ul\.to\)/"
MODULE_UPLOADING_REGEXP_URL="http://\(\w\+\.\)\?uploading.com/"
MODULE_USERSHARE_REGEXP_URL="http://\(www\.\)\?usershare.net/"
MODULE_X7_TO_REGEXP_URL="^http://\(www\.\)\?x7.to/"
MODULE_ZSHARE_REGEXP_URL="^http://\(www\.\)\?zshare.net/download"

OLDIFS=$IFS
IFS=$'\n'

rmok=0
bosseanouveau=0
RUNNING=0
if [[ -d /tmp/dlbot ]]
  then
    RUNNING=1
  else
    mkdir /tmp/dlbot /tmp/dlbot/wd /tmp/dlbot/todl /tmp/dlbot/multi
  fi

if [[ $# = 0 ]]
  then
# TODO : si running, relancer le daemon
    IFS=$OLDIFS
    exit 1
#     if [[ "`pidof -s -x -o %PPID /usr/share/apps/kate`" = "" ]]
#       then
# 	kate $HOME/scripts/dl.txt
#       else
# 	nano $HOME/scripts/dl.txt
#       fi
  else
    if [[ -d $1 ]]
      then
	DESTDIR="$1"
	shift
      else
	if [[ ! -d $HOME/Téléchargements ]]
	  then
	    mkdir $HOME/Téléchargements
	  fi
	DESTDIR="$HOME/Téléchargements"
      fi
    cd /tmp/dlbot/wd
    for URL in $@
      do
	INMOD=0
	for MODULE in ${MODULES[*]}
	  do
	    VAR=MODULE_$(echo $MODULE | tr '[a-z]' '[A-Z]')_REGEXP_URL
	    grep -q "${!VAR}" <<< "$URL" && echo "$URL" >> ../todl/$MODULE && INMOD=1 
	  done
	if [[ $INMOD = 0 ]]
	  then
	    wget $1
	  fi
      done
  fi

echo -en "\033[1m Fin de la première phase.\033[0m\n" 

if [[ $(ls | wc -l) != 0 ]]
  then
    for files in $(ls)
      do
	nom=$(echo "./$files" | sed "s/[][ -._\/]*//g" | sed "s/html//").nimed
	sed "s/>/>\n/g" ./$files | grep href | sed 's/.*<a href="//' | sed 's/".*//' > $nom # TODO y'a d'la place à gagner ici ^^'
	INMOD=0
	while read line
	  do
	    for MODULE in ${MODULES[*]}
	      do
		VAR=MODULE_$(echo $MODULE | tr '[a-z]' '[A-Z]')_REGEXP_URL
		grep -q "${!VAR}" <<< "$line" && echo $line >> ../multi/$nom && INMOD=1
	      done
	  done < $nom
	if [[ $INMOD = 0 ]]
	  then
	    echo -en "\033[5;31m Erreur ! Pas de liens vers des hébergeurs connus dans $files \033[0m\n"
	    mv -v "./$files" "$DESTDIR/$files"
	  else
	    rm "./$files"
	  fi
      done
  fi

echo -en "\033[1m Fin de la seconde phase.\033[0m\n" 

if [[ $RUNNING = 0 && $bosseanouveau = 1 ]]
  then
    while [[ $(cat $HOME/scripts/dl.txt | wc -l) != 0 ]]
      do
	todl=$(head $HOME/scripts/dl.txt -n 1 | cut --delimiter="=" -f 2)
	echo "TELECHARGEMENT DE http://www.megaupload.com/?d=$todl DANS $PWD"
	plowdown -a $MUUA http://www.megaupload.com/?d=$todl || echo " !!!!!!!!! PLOWDOWN erreur # $? !!!!!!!!!!!!! "
	sed -i "/$todl/d" $HOME/scripts/dl.txt
      done
    rm $HOME/scripts/dl.txt
  else
    echo "dlbot est en cours de fonctionnement => ajout des adresses dans la liste d'attente et fin du script."
    echo "Ou alors, Nim65s n'a pas fini de coder le script XD"
    IFS=$OLDIFS
    exit 2
  fi

cd /tmp/dlbot
for dos in wd todl multi
  do
    if [[ $(ls $dos | wc -l) != 0 ]]
      then
	rmdir $dos
      else
	echo -en "\033[5;31m ATTENTION ! Il reste des fichiers dans /tmp/dlbot/$dos : \033[0m\n"
	ls $dos
	rmok=1
      fi
  done
if [[ $rmok = 0 ]]
  then
    rmdir /tmp/dlbot
  fi

IFS=$OLDIFS
exit 0


# sed "/$(echo $todl | sed "s/[/]/\\\\\//g")/d" dl.txt