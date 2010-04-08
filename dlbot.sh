#!/bin/bash

# Script de gestion de files d'attentes et de pages contenant plusieurs liens pour le même fichier chez différents hébergeurs
# Fondé sur plowshare
# Écrit par Nim65s
# Licence GNU GPL v3

# TODO : plowdown -v donne la version :)
# TODO : beaucoup plus tard : ajouter la possibilité de dire qu'une page avec plein de liens, ben faut tous les télécharger :D genre l'option --mass :D
# TODO : arreter le un sous shell ?
# TODO : le case pour MU, c'est vraiment naze

# options : 
#       o : overpasser le verrou TODO
# codes de sortie : 
#               1 : déjà en fonctionnement => ajout des adresses dans la liste d'attente

# DEBUG : si le script a manifestement finit de télécharger mais ne s'arrête pas, c'est qu'il attend qu'il n'y ait plus de plowdown en cours. Si vous n'avez plus de téléchargement en cours, faites un "pkill plowdown"

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

miroriii_regexp_url="^http://\(www\.\)\?miroriii.com/"
OLDIFS=$IFS
IFS=$'\n'

NOMBRE=0
RUNNING=0
MIRORIII=0
[[ -d /tmp/dlbot ]] && RUNNING=1 && NOMBRE=$( ls /tmp/dlbot/multi | tail -n 1)

if [[ $# = 0 ]]
  then
# TODO : si running, relancer le daemon
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
# TODO : option pour virer ce fichier ?

lycos() # AKA Bac à sable... C'est faaaaaaaaaaaaaaaaux ! Mais le tout devrait continuer à marcher tant que y'a {{{ temporaire }}} :)
  {
    local MODULE_LY="$1"
    local TRY_LY="$2"
    local TRY_MAX_LY="$3"
    cd /tmp/dlbot/multi
    if [[ -f $TRY_LY ]]
      then
	if [[ $( tail -n 1 $TRY_LY ) != nim* ]]
	  then
	    VAR=MODULE_$(echo $MODULE_LY | tr '[a-z]' '[A-Z]')_REGEXP_URL
	    while read line
	      do
		if [[ $( grep -q "${!VAR}" <<< "$line" ) ]]
		  then
		    echo -e "nim\t$MODULE_LY" >> $TRY_LY
		    case $MODULE_LY in
		      megaupload )
			todl="$(head /tmp/dlbot/todl/megaupload -n 1)"
			plowdown -a $MUUA "$todl" -o $DESTDIR_UT || echo " !!!!!!!!! PLOWDOWN erreur # $? !!!!!!!!!!!!! "
			sed -i "/$(echo $todl | sed "s/.*[/]//g")/d" /tmp/dlbot/todl/megaupload
			;;
		      * )
			plowdown "$(head -n 1 /tmp/dlbot/todl/$1)" -o $DESTDIR_UT || echo " !!!!!!!!! PLOWDOWN erreur # $? !!!!!!!!!!!!! "
			sed -i "/$(echo $MODULE_UT | sed "s/.*[/]//g")/d" /tmp/dlbot/todl/$MODULE_UT
			;;
		      esac
		  fi
	      done < $TRY_LY
	  else
	    echo lol
	  fi
    elif [[ $TRY_LY -le $TRY_MAX_LY ]]
      then
	let "TRY_LY += 1"
	lycos $MODULE_LY $TRY_LY $TRY_MAX_LY
      fi
  }

unite_de_telechargement()
  {
    local MODULE_UT="$1"
    local DESTDIR_UT="$2"
    cd /tmp/dlbot/todl
    if [[ -f $MODULE_UT ]]
      then
	echo -e "\n\033[1m Unité de téléchargement : $MODULE_UT -- GO ! -- \033[0m"
	while [[ $(cat /tmp/dlbot/todl/$MODULE_UT | wc -l) != 0 ]]
	  do
	    echo -e "\n\033[1mTéléchargement de $(head -n 1 /tmp/dlbot/todl/$MODULE_UT) ===> $DESTDIR_UT\n\033[0m"
	    case $MODULE_UT in
	      megaupload )
		todl="$(head /tmp/dlbot/todl/megaupload -n 1)"
		plowdown -a $MUUA "$todl" -o $DESTDIR_UT || echo " !!!!!!!!! PLOWDOWN erreur # $? !!!!!!!!!!!!! " # TODO : on ajoute le lien à la table des ratés avant de le supprimer...
		sed -i "/$(echo $todl | sed "s/.*[/]//g")/d" /tmp/dlbot/todl/megaupload
		;;
	      * ) # TODO : ajouter un compte à rapidshare ?
		plowdown "$(head -n 1 /tmp/dlbot/todl/$1)" -o $DESTDIR_UT || echo " !!!!!!!!! PLOWDOWN erreur # $? !!!!!!!!!!!!! "
# 		sed -i "/$(echo $MODULE_UT | sed -i "s/[/]/\\\\\//g")/d" /tmp/dlbot/todl/$MODULE_UT
		sed -i "/$(echo $MODULE_UT | sed "s/.*[/]//g")/d" /tmp/dlbot/todl/$MODULE_UT
		;;
	      esac
	  done
	rm -v $MODULE_UT # TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO 
      fi
    # {{{
#     if [[ -d /tmp/dlbot/multi ]]
    if [[ $( ls /tmp/dlbot/multi 2> /dev/null | wc -l ) ]]
      then
	TRY_MAX=$( ls | sort -g | tail -n 1 )
	lycos $MODULE_UT 1 $TRY_MAX
      fi
    # }}}
    if [[ -f $MODULE_UT ]]
      then
	unite_de_telechargement $MODULE_UT $DESTDIR_UT
      fi
    echo -e "\n\n\033[1m Unité de téléchargement : $MODULE_UT -- DONE ! -- \n\033[0m"
  }

if [[ -d $1 ]]
  then
    DESTDIR="$1"
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
	nom=$(echo "./$files" | sed "s/[][ -._\/]*//g" | sed "s/html//").nimed
	sed "s/>/>\n/g" ./$files | grep href | sed 's/.*<a href="[ ]*//I' | sed 's/".*//' > $nom # TODO y'a d'la place à gagner ici ^^' --- le dernier sed pour rentrer dans 's/.*<a href="[ ]*//I' je suppose
	sed "s/>/>\n/g" ./$files | grep src | sed 's/.*src="[ ]*//I' | sed 's/".*//' >> $nom
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

# TODO : c'est un gros et moche copier coller...

if [[ $MIRORIII = 1 ]]
  then
    for files in $(ls)
      do
	nom=$(echo "./$files" | sed "s/[][ -._\/]*//g" | sed "s/html//").nimed
	sed "s/>/>\n/g" ./$files | grep href | sed 's/.*<a href="//I' | sed 's/".*//' | sed 's/^ //' > $nom # TODO y'a d'la place à gagner ici ^^'
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
	    echo -en "\033[5;31m Erreur ! Pas de liens vers des hébergeurs connus dans $files \033[0m\n"
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


# {{{ temporaire
cd /tmp/dlbot/multi
for files in $(ls)
  do 
    grep megaupload "$files" >> ../todl/megaupload || echo -en "\033[5;31m ATTENTION ! J'ai la flemme de télécharger les liens dans $files : $( cat $files ) \033[0m\n"
    rm -v $files
  done
# }}}

if [[ $RUNNING = 0 ]]
  then
# TODO TODO TODO TODO TODO TODO TODO TODO  TODO TODO TODO PARALLELISER! TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO
# # # # s'il n'y a pas/plus de ligne, il regarde dans chaque multi voir s'il y en a une
# # # # s'il n'en trouve pas, il se termine
# # # # s'il en trouve, il mémorise le nom du fichier, marque son nom à la fin et lance le téléchargement
# # # # quand il finit (!! sans erreur !!), il regarde s'il y a un autre nom que le sien à la fin du fichier
# # # # si non, il supprime le fichier
# # # # si oui, il se démerde pour expliquer à son pote qu'il faut arreter
# # # # "
# TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO

#   En attendant, pour que le script marche quand même... x)
    cd /tmp/dlbot/todl
    for files in $(ls)
      do
	unite_de_telechargement $files $DESTDIR  &
      done
    sleep 15
#     while [[ $( ps -ef | grep plowdown | grep -v grep | wc -l ) != 0 ]]
    while [[ $( pgrep plowdown ) ]]
      do
	sleep 15
      done
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
IFS=$OLDIFS
exit 0
