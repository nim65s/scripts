#!/bin/bash

code_de_sortie=0
declare -a MODULES_EN_FONCTIONNEMENT ADDRESSES_DE_BASE
declare -a MODULES
MODULES=(rapidshare megaupload 2shared badongo mediafire 4shared zshare depositfiles storage_to uploaded_to uploading netload_in usershare sendspace x7_to hotfile divshare dl_free_fr humyo filefactory data_hu)
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

miroriii_regexp_url="^http://\(www\.\)\?miroriii.com/"



initialisation()
  {
    echo -e "\033[1m-------------- Initialisation --------------\033[0m"
    mkdir $HOME/.BDL
  }


module()
  {
    specificite_du_module=""
    if [[ "$1" == "megaupload" ]]
      then
	specificite_du_module="-a $MUUA "
      fi
#     echo "$specificite_du_module -o $DESTDIR $2" >> $HOME/.BDL/.$1
    echo "$specificite_du_module$2" >> $HOME/.BDL/.$1
    if [[ "$( wc -l < $HOME/.BDL/.$1 )" == "1" ]]
      then
	while [[ $( wc -l < $HOME/.BDL/.$1 ) -gt 0 ]]
	  do
	    echo "plowdown $(head -n 1 $HOME/.BDL/.$1) || plowdown_erreur=?"
	    plowdown $(head -n 1 $HOME/.BDL/.$1) || plowdown_erreur=$?
	    if [[ $plowdown_erreur -gt 0 ]]
	      then
		echo -e "\033[5;31m Erreur plowdown $plowdown_erreur pour $(head -n 1 $HOME/.BDL/.$1).Renvoi de cette ligne au fond du fichier \033[0m"
		echo "$(head -n 1 $HOME/.BDL/.$1)" >> $HOME/.BDL/.$1
	      fi
	    sed -i '1d' $HOME/.BDL/.$1
	  done
      else
	echo "module $1 déjà en fonctionnement"
      fi
  }

miroriii()
  {
    mkdir "$(echo "$1" | sed 's/[/]/----/g')++++$(echo "$DESTDIR" | sed 's/[/]/----/g')"
    cd "$(echo "$1" | sed 's/[/]/----/g')++++$(echo "$DESTDIR" | sed 's/[/]/----/g')"
    wget -nv -O page_miroriii "$1"
    sed 's/"/\n/g' page_miroriii | sed "s/'/\n/g" | grep ^http > page_miroriii_parsed # marche pas si "url('http...')"
    while read line
      do
	for MODULE in ${MODULES[*]}
	  do
	    VAR=MODULE_$(echo $MODULE | tr '[a-z]' '[A-Z]')_REGEXP_URL
	    grep -q "${!VAR}" <<< "$adresse" && echo $line >> liste_des_telechargements
	  done
      done < page_miroriii_parsed
    touch FIN
    cd ..
  }

racine()
  {
    cd $1
    if [[ $(ls | wc -l) == 0 ]] # TODO sinon, vérifier que tout est fini ou reprendre les opérations ...
      then
	local adresse=$(echo $1 | sed 's/----/\//g;s/++++.*$//') # TODO reremplacer les autres caractères, cf. le mkdir de ce dossier, dans le "while [ $1 ]"
	INMOD=0
	for MODULE in ${MODULES[*]}
	  do
	    VAR=MODULE_$(echo $MODULE | tr '[a-z]' '[A-Z]')_REGEXP_URL
	    grep -q "${!VAR}" <<< "$adresse" && INMOD=1 && module $MODULE "$adresse"
	  done
	if [[ $INMOD = 0 ]]
	  then
	    grep -q $miroriii_regexp_url <<< "$adresse" && INMOD=1 && miroriii "$adresse"
	  fi
	if [[ $INMOD = 0 ]]
	  then
	    wget -nv -O page "$adresse"
	    sed 's/"/\n/g' page | sed "s/'/\n/g" | grep ^http > page_parsed
	    while read line
	      do
		grep -q $miroriii_regexp_url <<< "$line" && echo "$line" >> liste_des_miroriii
		for MODULE in ${MODULES[*]}
		  do
		    VAR=MODULE_$(echo $MODULE | tr '[a-z]' '[A-Z]')_REGEXP_URL
		    grep -q "${!VAR}" <<< "$line" && INMOD=1 && echo "$MODULE $line" >> liste_des_telechargements
		  done
	      done < page_parsed
	    if [[ -f liste_des_miroriii && -f liste_des_telechargements ]]
	      then
		echo "y'a une liste de miroriii et une liste de dl.. C'est n'importe quoi, je m'en fous, je fais rien :)"
	    elif [[ -f liste_des_telechargements ]]
	      then
		while read line
		  do
		    module $line # &
		  done < liste_des_telechargements
	    elif [[ -f liste_des_miroriii ]]
	      then
		echo EOF >> liste_des_miroriii
		while read line
		  do
		    [[ "$line" == "EOF" ]] && wait || { miroriii "$line" & }
		  done < liste_des_miroriii
	      else
		echo "rien à faire.... "
	      fi
	  fi
      fi
    cd ..
  }

if [[ ! -d $HOME/.BDL ]]
  then
    echo " c'est la première fois que vous lancez ce script. Initialisation… "
    initialisation
  fi

cd $HOME/.BDL

if [[  ! -d $DESTDIR ]]
  then
    mkdir -pv $HOME/Téléchargements
    DESTDIR="$HOME/Téléchargements"
  fi

while [ $1 ]
  do
    mkdir "$(echo "$1" | sed 's/[/]/----/g')++++$(echo "$DESTDIR" | sed 's/[/]/----/g')" # TODO y'a plus de choses que les / à remplacer ... ()[]{}\| etc. TROUVER LA LISTE
    shift
  done

for dossier_racine in $(ls | grep -v ^BDLOK ) FIN
  do
    [[ "$dossier_racine" = "FIN" ]] && wait || racine $dossier_racine & # > $dossier_racine/.log 2> $dossier_racine/.log.erreur
  done


exit $code_de_sortie