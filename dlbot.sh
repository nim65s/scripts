#!/bin/bash

# Script de gestion de files d'attentes et de pages contenant plusieurs liens pour le même fichier chez différents hébergeurs
# Fondé sur plowshare
# Écrit par Nim65s
# Licence GNU GPL v3

# TODO : plowdown -v donne la version :)
# TODO : beaucoup plus tard : ajouter la possibilité de dire qu'une page avec plein de liens, ben faut tous les télécharger :D genre l'option --mass :D
# TODO : arreter le un sous shell ?
# TODO : le case pour MU, c'est vraiment naze
# TODO : vérifier que si y'a une page miroriii qui link vers 12000 pages miroriii, ca pose pas de pb
# TODO : commencer par vérifier que les fichiers sont présents sur le serveur, virer ceux qui ne le sont pas 
#        ( sans rien dire si y'a d'autres liens dans un multi, sinon on l'affiche et modifie le code d'erreur ),
#        puis afficher tous les noms des fichiers à télécharger suivi de tous les hébergeurs disponibles
# TODO : le destdir sera toujours celui qui a été lancé en preums => génération d'un script éxécuté à la fin du daemon qui déplace les fichiers qui sont pas où il faut ?
# TODO : gestion des !
# TODO : sharabee == megaup
# BUG : 404 pour un miroriii => exit status 8 pour wget, cf le man.

# options :
#       o : overpasser le verrou TODO
# codes de sortie :
#               1 : déjà en fonctionnement => ajout des adresses dans la liste d'attente

# variables issues de plowshare v 0.9.3
declare -a MODULES
MODULES=(rapidshare megaupload 2shared badongo mediafire 4shared zshare depositfiles storage_to uploaded_to uploading netload_in usershare sendspace x7_to hotfile divshare dl_free_fr humyo filefactory data_hu 115)
MODULE_2SHARED_REGEXP_URL="http://\(www\.\)\?2shared\.com/file/"
MODULE_4SHARED_REGEXP_URL="http://\(www\.\)\?4shared\.com/file/"
MODULE_BADONGO_REGEXP_URL="http://\(www\.\)\?badongo\.com/"
MODULE_DATA_HU_REGEXP_URL="http://\(www\.\)\?data.hu/get/"
MODULE_DEPOSITFILES_REGEXP_URL="http://\(\w\+\.\)\?depositfiles.com/"
MODULE_DIVSHARE_REGEXP_URL="http://\(www\.\)\?divshare\.com/download"
MODULE_DL_FREE_FR_REGEXP_URL="http://dl.free.fr/"
MODULE_FILEFACTORY_REGEXP_URL="http://\(www\.\)\?filefactory\.com/file"
MODULE_HOTFILE_REGEXP_URL="^http://\(www\.\)\?hotfile\.com/"
MODULE_HUMYO_REGEXP_URL="http://\(www\.\)\?humyo\.com/"
MODULE_LETITBIT_REGEXP_URL="http://\(www\.\)\?letitbit\.net/"
MODULE_MEDIAFIRE_REGEXP_URL="http://\(www\.\)\?mediafire\.com/"
MODULE_MEGAUPLOAD_REGEXP_URL="^http://\(www\.\)\?mega\(upload\|rotic\|porn\).com/"
MODULE_NETLOAD_IN_REGEXP_URL="^http://\(www\.\)\?netload\.in/"
MODULE_RAPIDSHARE_REGEXP_URL="http://\(\w\+\.\)\?rapidshare\.com/"
MODULE_SENDSPACE_REGEXP_URL="http://\(www\.\)\?sendspace\.com/file/"
MODULE_STORAGE_TO_REGEXP_URL="^http://\(www\.\)\?storage\.to/get/"
MODULE_UPLOADED_TO_REGEXP_URL="^http://\(www\.\)\?\(uploaded\.to\|ul\.to\)/"
MODULE_UPLOADING_REGEXP_URL="http://\(\w\+\.\)\?uploading\.com/"
MODULE_USERSHARE_REGEXP_URL="http://\(www\.\)\?usershare\.net/"
MODULE_X7_TO_REGEXP_URL="^http://\(www\.\)\?x7\.to/"
MODULE_ZSHARE_REGEXP_URL="^http://\(www\.\)\?zshare\.net/\(download\|delete\)"
MODULE_115_REGEXP_URL="http://\(\w\+\.\)\?115\.com/file/"

# miroriii_regexp_url="^http://\(www\.\)\?miroriii.com/"
miroriii_regexp_url='gestdown.info\|mirorii'


OLDIFS=$IFS
IFS=$'\n'

declare -a DLOK
declare -a DLKO
DLOK=()
DLKO=()
#megaupload="-a $MUUA"
NOMBRE=0
RUNNING=0
MIRORIII=0
[[ -d /tmp/dlbot ]] && RUNNING=1 && NOMBRE=$( ls /tmp/dlbot/multi | tail -n 1)

if [[ $# = 0 ]]
  then
    IFS=$OLDIFS
    exit 1
  fi

while [[ -f /tmp/dlbot/STOP ]]
  do
    echo -n .
    sleep 1
  done
echo .
mkdir -pv /tmp/dlbot/wd /tmp/dlbot/todl /tmp/dlbot/multi /tmp/dlbot/multiwd
echo "Ce fichier est un verrou servant au script dlbot de ne pas s'embrouiller dans la recherche des fichiers à télécharger.
Il est détruit avant la phase de téléchargement pour permettre de reremplir les files d'attentes.
Si une autre instance du script est lancée tant que le verrou est actif, elle patientera gentiment en remplissant la page de petits points." > /tmp/dlbot/STOP


unite_de_telechargement()
  {
    local MODULE_UT="$1"
    local DESTDIR_UT="$2"
    local ERROR_UT=0
    local TODL_UT=""
    cd /tmp/dlbot/todl
    if [[ -f $MODULE_UT ]]
      then
	echo -e "\n\033[1m Unité de téléchargement : $MODULE_UT -- GO ! -- \033[0m"
	while [[ $(cat $MODULE_UT | wc -l) != 0 ]]
	  do
	    TODL_UT="$(head -n 1 /tmp/dlbot/todl/$MODULE_UT)"
	    echo -e "\n\033[1mTéléchargement de $TODL_UT ===> $DESTDIR_UT\n\033[0m"
	    #plowdown -a $MUUA "$TODL_UT" -o $DESTDIR_UT
	    plowdown "$TODL_UT" -o $DESTDIR_UT
	    ERROR_UT=$?
	    if [[ $ERROR_UT -gt 0 ]]
	      then
		echo " !!!!!!!!! PLOWDOWN FAIL : unité de téléchargement : $TODL_UT => $ERROR_UT !!!!!!!!!!!!! "
		date +"%x %X" >> $HOME/scripts/nim.error.log
		echo "FAIL : unité de téléchargement : $TODL_UT => $ERROR_UT " >> $HOME/scripts/nim.error.log
		sed -i "/$(echo $TODL_UT | sed "s/.*[/]//g")/d" $MODULE_UT
		DLKO=( ${DLKO[*]} $TODL_UT )
	      else
		date +"%x %X" >> $HOME/scripts/nim.log
		echo "SUCCESS : unité de téléchargement : $TODL_UT => $DESTDIR_UT" >> $HOME/scripts/nim.log
		sed -i "/$(echo $TODL_UT | sed "s/.*[/]//g")/d" $MODULE_UT
		DLOK=( ${DLOK[*]} $TODL_UT )
	      fi
	  done
	[[ $( wc -l < $MODULE_UT ) = 0 ]] && rm -v $MODULE_UT
      fi
    echo -e "\n\n\033[1m Unité de téléchargement : $MODULE_UT -- DONE ! -- \n\033[0m"
  }

if [[ -d $1 ]]
  then
    if [[ $(echo $1 | cut -d / -f 1) ]]
      then
	DESTDIR="$PWD/$1"
      else
	DESTDIR="$1"
      fi
    shift
  else
    mkdir -pv $HOME/Téléchargements
    DESTDIR="$HOME/Téléchargements"
  fi
cd /tmp/dlbot/wd

while [ $1 ]
  do
    INMOD=0
    for MODULE in ${MODULES[*]}
      do
	VAR=MODULE_$(echo $MODULE | tr '[a-z]' '[A-Z]')_REGEXP_URL
	grep -q "${!VAR}" <<< "$1" && INMOD=1  && echo "$1" >> ../todl/$MODULE
      done
    if [[ $INMOD = 0 ]]
      then
	wget -nv $1
      fi
    shift
  done

echo -en "\033[1m Fin de la phase de recherche des pages.\033[0m\n" 

if [[ $(ls | wc -l) != 0 ]]
  then
    for files in $(ls)
      do
	nom=$(echo "./$files" | sed "s/[][ -._\/]*//g;s/html//").nimed
	sed "s/>/>\n/g" ./$files | grep href | sed 's/.*<a href="[ ]*//I;s/".*//' > $nom
	sed "s/>/>\n/g" ./$files | grep src | sed 's/.*src="[ ]*//I;s/".*//' >> $nom
	sort $nom | uniq > $nom.uniq
	mv $nom.uniq $nom
	INMOD=0
	while read line
	  do
	    for MODULE in ${MODULES[*]}
	      do
		VAR=MODULE_$(echo $MODULE | tr '[a-z]' '[A-Z]')_REGEXP_URL
		grep -q "${!VAR}" <<< "$line" && INMOD=1 && echo $line >> ../multiwd/$nom
	      done
	  done < $nom
	if [[ $INMOD = 0 ]]
	  then
	    while read line
	      do
		grep -q "$miroriii_regexp_url" <<< "$line" && MIRORIII=1 && wget -nv "$line"
	      done < $nom
	  fi
	if [[ $INMOD = 0 && $MIRORIII = 0 ]]
	  then
	    echo -en "\033[5;31m Erreur ! Pas de liens vers des hébergeurs connus dans $files \033[0m\n"
	    mv -v "./$files" "$DESTDIR/$files"
	  else
	    rm "./$files" "$nom"
	  fi
      done
  fi

if [[ $MIRORIII = 1 ]]
  then
    for files in $(ls)
      do
	nom=$(echo "./$files" | sed "s/[][ -._\/]*//g;s/html//").nimed
	sed "s/>/>\n/g" ./$files | grep href | sed 's/.*<a href="//I;s/".*//;s/^ //' > $nom
	INMOD=0
	while read line
	  do
	    for MODULE in ${MODULES[*]}
	      do
		VAR=MODULE_$(echo $MODULE | tr '[a-z]' '[A-Z]')_REGEXP_URL
		grep -q "${!VAR}" <<< "$line" && INMOD=1 && echo "$line" >> ../multiwd/$nom
	      done
	  done < $nom
	if [[ $INMOD = 0 ]]
	  then
	    echo -e "\033[5;31m Erreur ! Pas de liens vers des hébergeurs connus dans $files \033[0m"
	    mv -v "./$files" "$DESTDIR/$files"
	  else
	    rm "./$files" "$nom"
	  fi
      done
  fi

if [[ $(ls ../multiwd | wc -l) != 0 ]]
  then
    cd ../multiwd
    for files in $(ls)
      do
	sort $files | uniq | grep -v //$ > $files.uniq
	rm $files
      done
    mv * ../wd
    cd ../wd
    for files in $(ls)
      do
	if [[ $(cat $files | wc -l) = 1 ]]
	  then
	    line="$(cat $files)"
	    for MODULE in ${MODULES[*]}
	      do
		VAR=MODULE_$(echo $MODULE | tr '[a-z]' '[A-Z]')_REGEXP_URL
		grep -q "${!VAR}" <<< "$line" && echo "$line" >> ../todl/$MODULE
	      done
	    rm $files
	  else
	    let "NOMBRE += 1"
	    mv $files ../multi/$NOMBRE
	  fi
      done
    cd ../todl
    for files in $(ls)
      do
	sort $files | uniq > $files.uniq
	mv $files.uniq $files
      done
    cd ../multi
    /usr/share/fslint/fslint/findup -d
#     declare -a ORPHANS
#     for((i=1;i<=$NOMBRE;i++))
#       do
# 	[[ $( ls | grep ^$i$ | wc -l ) = 0 ]] && ORPHANS=( ${ORPHANS[*]} $i )
#       done
#     for((i=0;i<${#ORPHANS[*]};i++))
#       do
# 		là, faudrait déplacer les derniers fichiers dans les trous... Mais c'est pas primordial ^^'
#       done
    let "NOMBRE -= ${#ORPHANS[*]}"
    echo -en "\033[1m Fin de la phase de recherche des liens dans les pages.\033[0m\n"
  fi

cd ..
rmdir -v wd multiwd --ignore-fail-on-non-empty
[[ $(ls /tmp/dlbot/todl | wc -l) != 0 ]] && directdl=$(cat /tmp/dlbot/todl/* | wc -l) || directdl=0
echo -e "\033[1m dlbot a trouvé $directdl fichier(s) à télécharger directement et $NOMBRE fichier(s) à télécharger en parallèle.\033[0m"
echo -e "Levage du verrou : vous pouvez à nouveau lancer une autre instance de ce script, par exemple pour ajouter d'autres choses dans les listes d'attente ;,,,;" # TODO euh... doublons ?
rm /tmp/dlbot/STOP

cd /tmp/dlbot/multi
for files in $(ls)
  do 
    grep megaupload "$files" >> ../todl/megaupload || echo -en "\033[5;31m ATTENTION ! J'ai la flemme de télécharger les liens dans $files : $( cat $files ) \033[0m\n"
    rm -v $files
  done

if [[ $RUNNING = 0 ]]
  then
    cd /tmp/dlbot/todl
    unite_de_telechargement megaupload $DESTDIR
  else
    echo "dlbot est en cours de fonctionnement => ajout des adresses dans la liste d'attente et fin du script."
    IFS=$OLDIFS
    exit 1
  fi
cd 
for dos in "/tmp/dlbot/wd" "/tmp/dlbot/todl" "/tmp/dlbot/multi" "/tmp/dlbot/multiwd"
  do
    [[ -d $dos ]] && if [[ $(ls $dos | wc -l) = 0 ]]
      then
	rmdir -pv $dos --ignore-fail-on-non-empty
      else
	echo -en "\033[5;31m ATTENTION ! Il reste des fichiers dans $dos : \033[0m\n"
	ls $dos
      fi
  done

echo -e "\n\033[1m Fin du script. \033[0m"
if [[ ${#DLOK[*]} -gt 0 ]]
  then
    echo -e "\n\033[1m Téléchargés avec succés : \033[0m"
    echo ${DLOK[*]}
  fi
if [[ ${#DLKO[*]} -gt 0 ]]
  then
    echo -e "\033[5;31m Téléchargements ratés : \033[0m"
    echo ${DLKO[*]}
  fi

IFS=$OLDIFS
exit 0
