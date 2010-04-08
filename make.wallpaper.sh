#!/bin/bash

# Script de gestion d'une "base de données" de fond d'écrans.
# Utilise findup de fslint, Copyright 2000-2009 by Padraig Brady <P@draigBrady.com>,
# donc sous licence GNU GPL v3.
# Écrit par Nim65s.

OLDIFS=$IFS
IFS=$'\n'
ACTION="mv"
sortie=0
modif=0
nombreactuel=$(ls $HOME/images/wall/ | cut --delimiter="." -f 1 | sort -g | tail -n 1)
echo "makewallpaper : $nombreactuel fonds d'écran déjà présents"

afficher_aide()
  {
    echo "usage : makewallpaper [ fichiers ] [ -m  fichiers [ -c ]] fichiers"
    echo "          déplace les fichiers dans le répertoire $HOME/images/wall en leur attribuant un numero"
    echo "          puis met à jour le script wallpaper.sh avec le nouveau nombre de fonds d'écran"
    echo "          les fichiers mentionnés après l'option -c seront copiés plutôt que déplacés"
    echo "          les fichiers mentionnés après l'option -m seront à nouveau déplacés plutôt que copiés"
    echo "        makewallpaper -d"
    echo "          supprime les doublons et met l'index à jour"
    echo "        makewallpaper -h"
    echo "          affiche cette aide"
    echo "Code de sortie :"
    echo "             0 : le script s'est déroulé sans encombres"
    echo "             1 : mauvais argument"
    echo "Dépendance : fslint <http://www.pixelbeat.org/fslint/> ( uniquement pour l'option -d )"
    echo "                    'findup' doit se trouver dans /usr/share/fslint/fslint/"
  }

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
      d | -d )
# TODO : bug si ${#ORPHANS[*]} > nombre de fichiers à déplacer.
	adresseactuelle=$PWD
	cd $HOME/images/wall/
	/usr/share/fslint/fslint/findup -d
	declare -a ORPHANS
	for((i=1;i<=$nombreactuel;i++))
	  do
	    [[ $(ls | grep ^$i[.] | wc -l) == 0 ]] && ORPHANS=( ${ORPHANS[*]} $i )
	  done
	echo "Il y a actuellement ${#ORPHANS[*]} orphelin(s)"
	let "nombreactuel -= ${#ORPHANS[*]}"
	for((i=0;i<${#ORPHANS[*]};i++))
	  do
	    [[ $(ls | sort -g | tail -n 1 | cut --delimiter="." -f 1 ) -gt ${ORPHANS[$i]} ]] && mv -v $(ls | sort -g | tail -n 1) ${ORPHANS[$i]}.$(ls | sort -g | tail -n 1 | cut --delimiter="." -f 2-)
	    modif=1
	  done
	shift
	cd $adresseactuelle
	;;
      h | -h )
	afficher_aide
	;;
      *)
	if [[ -f $1 ]]
	  then
	    let "nombreactuel += 1"
	    $ACTION -v $1 $HOME/images/wall/$nombreactuel.$1
	    modif=1
	  else
	    echo -e "\033[5;31mMauvais arugment ! ($1)\033[0m"
	    afficher_aide
	    sortie=1
	  fi
	shift
	;;
      esac
  done

if [[ $modif = 1 ]]
  then
    echo "nombre=$nombreactuel > wallpaper.sh"
    sed -i "s/nombre=[0-9]*/nombre=$nombreactuel/" $HOME/scripts/wallpaper.sh
  fi

IFS=$OLDIFS
exit $sortie
