#!/bin/bash
# TODO : curl plutot que wget dans le cas où plus.php & index.php seraient dépassés
# TODO : intégration à awesome en lancement avec Kalarm
# TODO : gestion de toutes les erreurs possibles et imaginables
# TODO : verification qu'on a pas manqué un chapitre
# TODO : et si y'avait un lien direct vers MU ? ou autre chose ?
# TODO : tomage automatique
# TODO : http://www.n-c-team.com/flux_rss2.xml : rss => facile => le même ?
# TODO : code d'erreur de plowshare
# TODO : exploser les arguments avant de les regarder, qu'on puisse dire flo
# TODO : option i : interactive
# TODO : chercher dans les dossiers actuels si y'a pas déjà des trucs interessants, toussa.. peut être que le nom n'est pas approprié...
# TODO : exploser systematiquement toutes les pages web téléchargées avec sed '"s/>/>\n/g"' NON => faut garder une unité sur les blocs pour titre date, etc.
# TODO : ranger les codes de sortie proprement
# TODO : passer $HOME/scripts/autodl.txt en autodl.rc, et déclarer les variables dans celui-ci.

OLDIFS=$IFS
IFS=$'\n'

declare -a SITES
declare -a ADDRSITES
declare -a DATESSITES
declare -a scantrad
declare -a japanshin
declare -a dossieralire
SITES=( scantrad japanshin )
ADDRSITES=( http://www.scantrad.fr/rss/ http://www.japan-shin.com/ )
DATESSITES=( \<pubDate\> \<td\ width=\"150\"\ bgcolor=\"#333333\"\>\<\em\> )
scantrad=( Naruto OnePiece CodeBreaker)
japanshin=( Kenichi )
dlscantrad=0
dljapanshin=0
force=0
lire=0
downloadonly=0
sortie=0

afficher_aide_et_sortir()
  {
    echo "nimautdl usage : "
    echo '$HOME/scripts/nimautodl.sh [o] [f] [d]'
    echo " options : "
    echo "       o : outrepasse le vérou "
    echo "       f : force la mise à jour sans tenir compte de la date "
    echo "       d : télécharger seulement, ne pas lire ni archiver "
    echo " code de sortie : "
    echo "              0 : le script s'est déroulé sans encombres."
    echo "              1 : vérou présent, rien ne s'est passé."
    echo "              2 : vérou présent sur dl.sh, les fichiers sont téléchargés dans \$HOME/Téléchargements."
    echo "              3 : mauvais arguments, affichage de l'aide et sortie."
    echo "              4 : des dossiers n'ont pas pu être classés, ils sont allés dans \$HOME/nimautodl."
    echo "              5 : plowdown est en fonctionnement, et l'utilisateur a décidé de sortir."
    IFS=$OLDIFS
    exit 3
  }

while [[ $1 ]]
  do
    case $1 in
      d )
	downloadonly=1
	;;
      f )
	force=1
	;;
      o )
	if [[ -e /tmp/autodl/autodl.stop ]]
	  then
	    rm /tmp/autodl/autodl.stop
	  fi
	;;
      * )
	afficher_aide_et_sortir
	;;
      esac
    shift
  done

if [[ ! -d /tmp/autodl ]]
  then
    mkdir /tmp/autodl
  fi
cd /tmp/autodl

if [[ -e /tmp/autodl/autodl.stop ]]
  then
    IFS=$OLDIFS
    exit 1
  else
    touch /tmp/autodl/autodl.stop
    if [[ "`pidof -s -x -o %PPID plowdown`" != "" ]]
      then
	echo -en "\033[5;31mATTENTION ! Plowdown est en cours de fonctionnement. Que faire ?\033[0m\n" 
	echo -en "          \033[1m Tuer / Sortir / Continuer ? \033[0m"
	read -n 1 reponse
	  case $reponse in
	    T* | t* )
	      $HOME/scripts/meurs.sh plowdown
	      ;;
	    S* | s* )
	      rm -v /tmp/autodl/autodl.stop
	      IFS=$OLDIFS
	      exit 5
	      ;;
	    C* | c* )
	      echo "\nReprise du script... À vos risques et périls ;)"
	      ;;
	    * )
	      rm -v /tmp/autodl/autodl.stop
	      afficher_aide_et_sortir
	      ;;
	    esac
      fi
  fi

for((i=0;i<${#scantrad[*]};i++))
  do
    declare ${scantrad[$i]}=$(ls $HOME/Scans/${scantrad[$i]} | sort -g | tail -n 1)
    echo ${scantrad[$i]} : ${!scantrad[$i]}
  done
kenichi=$(ls $HOME/Scans/Kenichi | sort -g | tail -n 1)
echo Kenichi : $kenichi

if [[ $force = 1 ]]
  then
    rm $HOME/scripts/autodl.txt
  fi
touch $HOME/scripts/autodl.txt

for((i=0;i<${#SITES[*]};i++))
  do
    wget -nv "${ADDRSITES[$i]}"
    nouvelledate=$(grep "${DATESSITES[$i]}" index.html | head -n 1 | sed "s/[ \t]*${DATESSITES[$i]}//" | sed "s/<.*//") # TODO cet index est un problème majeur... Et il faudrait exploser toutes les balises
    if [[ "${SITES[$i]}:$nouvelledate" == "$(grep ${SITES[$i]} $HOME/scripts/autodl.txt)" ]]
      then
	echo "pas de mises à jour sur ${ADDRSITES[$i]}"
	rm index.html
      else
	echo "mises à jours disponibles sur ${ADDRSITES[$i]} !!!"
	echo "Ancienne date : $(grep ${SITES[$i]} $HOME/scripts/autodl.txt | sed "s/${SITES[$i]}://")"
	echo "Nouvelle date : $nouvelledate"
	echo "${SITES[$i]}:" >> $HOME/scripts/autodl.txt
	FICHIER=$(mktemp)
	sed "s/^${SITES[$i]}:.*/${SITES[$i]}:$nouvelledate/" $HOME/scripts/autodl.txt | sort | uniq > $FICHIER
	mv $FICHIER $HOME/scripts/autodl.txt # TODO ces trois lignes là, faut apprendre à le faire qu'avec un sed...
	mv index.html ${SITES[$i]}
      fi
  done

if [[ -e scantrad ]]
  then
    echo -en "\033[1m-------------- Analyse de scantrad --------------\033[0m\n"
    FICHIER=$(mktemp)
    sed -e :a -e "/title>$/N; s/\n[ \t]*//; ta" scantrad | grep '<title>' > $FICHIER # TODO : tenter un sed -i < grep ?
    while read line
      do
	titre=$(echo $line | sed "s/<title>//" | sed "s/<.*//" | sed "s/[[:space:]][[:space:]]*/ /g") # je viens d'ajouter le dernier sed
	serie=$(echo $titre | sed "s/[ \t0-9:]//g")
	if [[ "$serie" == "${scantrad[0]}" || "$serie" == "${scantrad[1]}" || "$serie" == "${scantrad[2]}" ]] # TODO ça c'est moche :s
	  then
	    chapitre=$(echo $titre | sed "s/[ a-zA-Z:]//g")
	    if [[ $chapitre -gt ${!serie} ]]
	      then
		echo -en "\033[1m$titre trouvé et plus récent que le dernier chapitre de $serie présent sur le disque (${!serie}) !\033[0m\n"
		dlscantrad=1
		[[ $downloadonly = 0 ]] && lire=1
		wget -nv $(echo $line | sed 's/.*<link>//' | sed 's/<.*//')
	      else
		echo "$titre trouvé mais <= ${!serie}"
	      fi
	  fi
      done < $FICHIER
      rm scantrad $FICHIER
  fi

if [[ $dlscantrad = 1 ]]
  then
    for todl in plus.php*
      do
	FICHIER=$(mktemp)
	grep 'class="telecharger"' $todl | sed 's/.*href="//' | sed 's/".*//' > $FICHIER
	wget -nv -i $FICHIER
	rm $todl $FICHIER
      done
  fi

# TODO  : kenichi => $serie

if [[ -e japanshin ]]
  then
    echo -en "\033[1m-------------- Analyse de japanshin --------------\033[0m\n"
    FICHIER=$(mktemp)
    sed "s/<\/td>.*/<\/td>\\\/" japanshin | sed -e :a -e '/\\$/N; s/\\\n[ \t]*//; ta ' | grep '<td width="225" bgcolor="#333333">' > $FICHIER
    while read line
      do
	titre=$(echo $line | cut --delimiter=">" -f 7 | sed "s/<\/td//") # ajouter le meme sed que dans scantrad ?
	serie=$(echo $titre | sed "s/\/Tome//" | sed "s/[/ 0-9]//g")
	if [[ $serie = Kenichi ]]
	  then
	    chapitre=$(echo $titre | sed "s/[/].*//" | sed "s/[ a-zA-Z/]//g")
	    if [[ $chapitre -gt $kenichi ]]
	      then
		echo -en "\033[1m$titre trouvé et plus récent que le dernier chapitre de Kenichi présent sur le disque ($kenichi) !\033[0m\n"
		dljapanshin=1
		[[ $downloadonly = 0 ]] && lire=1
		wget -nv "$(echo $line | cut --delimiter=">" -f 14 | sed 's/<a href="/http:\/\/www.japan-shin.com/'# | sed 's/"//' | sed 's/\&amp;/\&/g')" # TODO c'est quoi ce # en plein milieu ? oO
	      else
		echo "$titre trouvé mais <= ($kenichi)"
	      fi
	  fi
      done < $FICHIER
    rm japanshin $FICHIER
  fi

if [[ $dljapanshin = 1 ]]
  then
    for todl in index.php*
      do
	wget "$(sed "s/>/>\n/g" ./$todl | grep miroriii | sed 's/.*http:\/\///' | sed 's/".*//' | sed "s/ /\\\ /g")" # TODO au lieu de wget, on >> listeafileradlbot
	rm ./$todl 
      done
  fi

if [[ $dljapanshin == 1 || $dlscantrad == 1 ]]
  then
    echo -en "\033[1m-------------- Téléchargements des nouveaux chapitres ! --------------\033[0m\n"
    for todl in $(ls | grep -v autodl.stop) # TODO C'est mooooche x)
      do
	mv -v "./$todl" todl
	$HOME/scripts/dl.sh $PWD "$(grep http://www.megaupload.com todl | sed "s/.*http:\/\/www.megaupload.com/http:\/\/www.megaupload.com/" | sed 's/".*//')" # TODO euh... NUL ! vive dlbot !
	if [[ $? = 1 ]]
	  then
	    echo -en "\033[5;31m ATTENTION ! Le téléchargement a été placé en file d'attente. Les fichiers seront téléchargés dans $HOME/nimdl \033[0m\n"
	    sortie=2
	  fi
      done
    rm todl
    echo -en "\033[1m-------------- Extraction --------------\033[0m\n"
    $HOME/scripts/extracteur.sh -r
  fi

if [[ $lire = 1 ]]
  then
    echo -en "\033[1m-------------- Place à la lecture et à l'archivage --------------\033[0m\n"
    dossieralire=( /tmp/autodl )
    for dos in nimautodl
      do
	if [[ -d $HOME/$dos ]]
	  then
	    dossieralire=( ${dossieralire[*]} $HOME/$dos )
	  fi
      done
    for fold in ${dossieralire[*]}
      do
	cd $fold
	for dos in $(ls | grep -v autodl.stop)
	  do
	    feh -FZrSname $dos
	    chapitre=$(echo $dos | sed "s/\xf8//" | sed "s/[^0-9]//g")
	    case $dos in
	      *enichi* )
		serie=Kenichi
		;;
	      *ne*iece* )
		serie=OnePiece
		;;
	      *aruto* )
		serie=Naruto
		;;
	      *de*reaker* )
		serie=CodeBreaker
		;;
	      * )
		if [[ ! -d $HOME/nimautodl ]]
		  then
		    mkdir $HOME/nimautodl
		  fi
		serie="../nimautodl"
		chapitre=$dos
		echo -en "\033[5;31mATTENTION ! Autodl n'a pas pu déterminer de quelle série il s'agissait pour $dos, il ira donc dans \$HOME/nimautodl.\033[0m\n"
		echo "Ceci est une faute de jeunesse du script et d'inexpérience de Nim65s. Il corrigera ça dès qu'il pourra."
		sortie=4 # bugreport : soucis avec le mv qui suit ca marche pas les ..
		;;
	      esac
	    mv -v $dos $HOME/Scans/$serie/$chapitre
	  done
      done
    cd /tmp/autodl
  else
    if [[ $(ls | grep -v autodl.stop | wc -l) -gt 0 ]]
      then
	if [[ ! -d $HOME/nimautodl ]]
	  then
	    mkdir $HOME/nimautodl
	  fi
	mv -v $(ls | grep -v autodl.stop) $HOME/nimautodl
      fi
  fi

rm -v /tmp/autodl/autodl.stop

if [[ $(ls /tmp/autodl | wc -l) = 0 ]]
  then
    rmdir /tmp/autodl
  else
    echo -en "\033[5;31m Il reste des fichiers dans /tmp/autodl :\033[0m\n"
    ls -A /tmp/autodl
  fi

IFS=$OLDIFS
exit $sortie
