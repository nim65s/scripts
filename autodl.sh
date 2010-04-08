#!/bin/bash
# TODO : curl plutot que wget dans le cas où plus.php & index.php seraient dépassés
# TODO : intégration à awesome en lancement avec Kalarm
# TODO : gestion de toutes les erreurs possibles et imaginables
# TODO : et si y'avait un lien direct vers MU ? ou autre chose ?
# TODO : tomage automatique
# TODO : http://www.n-c-team.com/flux_rss2.xml : rss => facile => le même ?
# TODO : code d'erreur de plowshare
# TODO : chercher dans les dossiers actuels si y'a pas déjà des trucs interessants, toussa.. peut être que le nom n'est pas approprié...
# TODO : exploser systematiquement toutes les pages web téléchargées avec sed '"s/>/>\n/g"' NON => faut garder une unité sur les blocs pour titre date, etc.
# TODO : ranger les codes de sortie proprement
# TODO : passer $HOME/scripts/autodl.txt en autodl.rc, et déclarer les variables dans celui-ci.
# TODO : pour éviter tous ces horribles "ls | grep -v autodl.stop"on pourrait créer un dossier par site et bosser dans celui-ci.
# TODO : fonction lire pour avoir la possibilité de la lancer avant la MàJ ? En attendant, faut lancer le script tant que y'a pas de MàJ, ou le lancer et le stopper dès que le fichier autodl.txt a été écrit...
# TODO : prendre en compte les fichiers/dossiers déjà présent devrait influer sur les fichiers à télécharger
# TODO : par défaut, tout est excessivement verbeux... Créer des niveaux verbosity ?
#        la verbosité peut agir sur cp mv mkdir rmdir wget ( qui a l'option -v par défaut et qu'on enlève avec -nv ) et plowdown ( -q )

OLDIFS=$IFS
IFS=$'\n'

declare -a arguments
declare -a SITES
declare -a ADDRSITES
declare -a DATESSITES
declare -a scantrad
declare -a japanshin
declare -a dossieralire
declare -a todlbot
SITES=( scantrad japanshin )
ADDRSITES=( http://www.scantrad.fr/rss/ http://www.miroriii.com/dossier/2304/kenichi%20release.html )
DATESSITES=( \<pubDate\> \<td\ width=\"150\"\ bgcolor=\"#333333\"\>\<\em\> )
scantrad=( Naruto OnePiece CodeBreaker )
japanshin=( Kenichi )
todlbot=()
dlscantrad=0
dljapanshin=0
force=0
lire=0
downloadonly=0
sortie=0
interactif=0
quick=0

codesortie() 
  { 
    if [[ $sortie = 0 ]]
      then
	echo -e "\033[5;31m Code de sortie modifié en $1 \033[0m"
	sortie=$1
      else
	echo -e "\033[5;31m Codes de sortie $sortie et $1 => il sera désormais 65 \033[0m"
	sortie=65
      fi
  }

afficher_aide_et_sortir()
  {
    echo "nimautdl usage : "
    echo '$HOME/scripts/nimautodl.sh [ofldviq]'
    echo " Options : "
    echo "       o : Outrepasse le vérou "
    echo "       f : Force la mise à jour sans tenir compte de la date "
    echo "       l : Prend en compte les anciens téléchargements "
    echo "       d : Télécharge seulement "
    echo "       v : Vérifie seulement si tous les chapitres sout bien là "
    echo "       i : Archivage Interactif " # TODO : what else ?
    echo "       q : Quick : ne pas vérifier les chapitres " # TODO : what else ?
    echo " NB : tout autre argument affiche cette aide "
    echo " Code de sortie : "
    echo "              0 : Le script s'est déroulé sans encombres."
    echo "              1 : Vérou présent, rien ne s'est passé. HASBEEN : le script attend gentiment son tour en affichant des petits points :D"
    echo "              2 : Vérou présent sur dl.sh, les fichiers sont téléchargés dans \$HOME/Téléchargements."
    echo "              3 : Mauvais arguments, affichage de l'aide et sortie."
    echo "              4 : Des dossiers n'ont pas pu être classés, ils sont allés dans \$HOME/nimautodl."
    echo "              5 : Plowdown est en fonctionnement, et l'utilisateur a décidé de sortir."
    echo "              6 : Il manque un/des chapitre(s). "
    echo "             65 : Plusieurs erreurs ! :p "
    echo " Dépendances : 'meurs.sh', 'extracteur.sh' et provisoirement 'dl.sh'."
    echo "             : à situer dans \$HOME/scripts/" # TODO : pas top ^^'
    IFS=$OLDIFS
    codesortie 3
    exit $sortie
  }

verification_manque_chapitre()
  {
    echo -e "\033[1m-------------- Vérification des chapitres --------------\033[0m"
    manqueoverall=0
    for dos in ${scantrad[*]} ${japanshin[*]}
      do
	manque=0
	cd $HOME/Scans/$dos
	FIRST=$( ls | grep -v Tome | sort -g | head -n 1)
	LAST=$( ls | grep -v Tome | sort -g | tail -n 1)
	echo "vérification des chapitres dans $HOME/Scans/$dos, de $FIRST à $LAST"
	for((i=$FIRST;i<=$LAST;i++))
	  do 
	    if [[ -d $i || -d 0$i || -d 00$i ]]
	      then 
		echo -n .
	      else 
		let manque+=1
		let manqueoverall+=1
		echo -en "\033[5;31m-$i\033[0m"
	      fi
	  done
	[[ $manque = 0 ]] && echo "OK" || echo -e "\033[5;31m Il semblerait qu'il manque $manque chapitre(s) de $dos !!!\033[0m"
      done
    if [[ $manqueoverall = 0 ]]
      then
	echo -e "\033[1m Il semblerait que tous les chapitres soient là ! \033[0m"
      else
	echo -e "\033[5;31m Il semblerait qu'il manque en tout $manqueoverall chapitre(s) !!!\033[0m"
	codesortie 6
      fi
  }

for args in $@
  do
    arguments=( ${arguments[*]} $(echo $args | sed 's/./& /g') )
  done
IFS=$OLDIFS
for args in ${arguments[*]}
  do
    case $args in
      d )
	downloadonly=1
	;;
      l )
	lire=1
	;;
      f )
	force=1
	;;
      o )
	[[ -e /tmp/autodl/autodl.stop ]] && rm /tmp/autodl/autodl.stop
	;;
      v )
	verification_manque_chapitre
	IFS=$OLDIFS
	exit $sortie
	;;
      i )
	interactif=1
	;;
      q )
	quick=1
	;;
      * )
	afficher_aide_et_sortir
	;;
      esac
  done
IFS=$'\n'

mkdir -pv /tmp/autodl
cd /tmp/autodl

while [[ -f /tmp/autodl/autodl.stop ]]
  do
    echo -n .
    sleep 1
  done
echo .
echo "Ce fichier est un verrou servant au script autodl de ne pas s'embrouiller dans la recherche des fichiers à télécharger.
Si une autre instance du script est lancée tant que le verrou est actif, elle patientera gentiment en remplissant la page de petits points." > /tmp/autodl/autodl.stop
if [[ "$(pidof -s -x -o %PPID plowdown)" != "" ]]
  then
    echo -e "\033[5;31mATTENTION ! Plowdown est en cours de fonctionnement. Que faire ?\033[0m" 
    echo -en "          \033[1m Tuer / Sortir / Continuer ? \n ==> \033[0m"
    read -n 1 reponse
      case $reponse in
	T* | t* )
	  $HOME/scripts/meurs.sh plowdown
	  ;;
	S* | s* )
	  rm -v /tmp/autodl/autodl.stop
	  IFS=$OLDIFS
	  codesortie 5
	  exit $sortie
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

for var in ${scantrad[*]}
  do
    declare $var=$(ls $HOME/Scans/$var | sort -g | tail -n 1)
    echo $var : ${!var}
  done
kenichi=$(ls $HOME/Scans/Kenichi | sort -g | tail -n 1)
echo Kenichi : $kenichi
[[ $force = 1 ]] && rm $HOME/scripts/autodl.txt
touch $HOME/scripts/autodl.txt

# for((i=0;i<${#SITES[*]};i++))
#   do
i=0 # modif à cause de JS
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
#   done

if [[ -e scantrad ]]
  then
    echo -e "\033[1m-------------- Analyse de scantrad --------------\033[0m"
    FICHIER=$(mktemp)
    sed -e :a -e "/title>$/N; s/\n[ \t]*//; ta" scantrad | grep '<title>' > $FICHIER # TODO : tenter un sed -i < grep ?
    while read line
      do
	titre=$(echo $line | sed "s/<title>//" | sed "s/<.*//" | sed "s/[[:space:]][[:space:]]*/ /g")
	serie=$(echo $titre | sed "s/[ \t0-9:]//g")
	if [[ "$serie" == "${scantrad[0]}" || "$serie" == "${scantrad[1]}" || "$serie" == "${scantrad[2]}" ]] # TODO ça c'est moche :s
	  then
	    chapitre=$(echo $titre | sed "s/[ a-zA-Z:]//g")
	    if [[ $chapitre -gt ${!serie} ]]
	      then
		echo -e "\033[1m$titre trouvé et plus récent que le dernier chapitre de $serie présent sur le disque (${!serie}) !\033[0m"
		dlscantrad=1
		[[ $downloadonly = 0 ]] && lire=1
		todlbot=( ${todlbot[*]} "$(echo $line | sed 's/.*<link>//' | sed 's/<.*//')")
	      else
		echo "$titre trouvé mais <= ${!serie}"
	      fi
	  fi
      done < $FICHIER
      rm scantrad $FICHIER
  fi

echo -e "\033[1m-------------- Analyse de japanshin --------------\033[0m"
wget -nv "http://www.miroriii.com/dossier/2304/kenichi%20release.html"
FICHIER=$(mktemp)
sed "s/>/>\n/g" kenichi\ release.html | grep miroriii | grep Kenichi | grep -v Tome | sed 's/.*http:\/\///' | sed "s/'.*//" | sed "s/ /\\\ /" > $FICHIER
while read line
  do
    chapitre=$(cut --delimiter=" " -f 2 <<< $line | sed "s/-.*//")
    if [[ "$chapitre" -gt "$kenichi" ]]
      then
	echo -e "\033[1m$line trouvé et plus récent que le dernier chapitre de Kenichi présent sur le disque ($kenichi) !\033[0m"
	dljapanshin=1
	[[ $downloadonly = 0 ]] && lire=1
# 	    $HOME/scripts/dlbot.sh $PWD "$(grep "$chapitre" "$FICHIER")"
	todlbot=( ${todlbot[*]} "$(grep "$chapitre" "$FICHIER")")
      else
	echo "$line trouvé mais <= ($kenichi)"
      fi
  done < $FICHIER
rm kenichi\ release.html $FICHIER


if [[ $dljapanshin == 1 || $dlscantrad == 1 ]]
  then
    echo -e "\033[1m-------------- Téléchargements des nouveaux chapitres ! --------------\033[0m"
    echo -e "\033[1m.............. Passage du flambeau à dlbot ..............\033[0m"
#     for todl in $(ls | grep -v autodl.stop) # TODO C'est mooooche x)
#       do
# 	echo -en "\n\n"
# 	mv -v "./$todl" todl
# 	echo -en "\n"
# 	$HOME/scripts/dl.sh $PWD "$(grep http://www.megaupload.com todl | sed "s/.*http:\/\/www.megaupload.com/http:\/\/www.megaupload.com/" | sed 's/".*//')" # TODO euh... NUL ! vive dlbot !
# 	if [[ $? = 1 ]]
# 	  then
# 	    echo -e "\033[5;31m ATTENTION ! Le téléchargement a été placé en file d'attente. Les fichiers seront téléchargés dans $HOME/nimdl \033[0m"
# 	    sortie=2
# 	  fi
#       done
#     rm todl
    $HOME/scripts/dlbot.sh $PWD ${todlbot[*]}
    echo -e "\033[1m.............. Reprise du flambeau à dlbot ..............\033[0m"
    echo -e "\033[1m-------------- Extraction --------------\033[0m"
    $HOME/scripts/extracteur.sh -r
    rm */*/Thumbs.db 2>> /dev/null
  fi

if [[ $lire = 1 ]]
  then
    echo -e "\033[1m-------------- Place à la lecture et à l'archivage --------------\033[0m"
    dossieralire=( /tmp/autodl )
    for dos in $HOME/nimautodl
      do
	[[ -d $dos ]] && dossieralire=( ${dossieralire[*]} $dos )
      done
    for fold in ${dossieralire[*]}
      do
	cd $fold
	for dos in $(ls | grep -v autodl.stop) # TODO : vérifier que c'est des dossiers, éventuellement avec des images...
	  do
	    rm -v */Thumbs.db
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
		mkdir -pv $HOME/nimautodl
		serie="../nimautodl"
		chapitre=$dos
		echo -e "\033[5;31mATTENTION ! Autodl n'a pas pu déterminer de quelle série il s'agissait pour $dos, il ira donc dans \$HOME/nimautodl.\033[0m"
		echo "Ceci est une faute de jeunesse du script et d'inexpérience de Nim65s. Il corrigera ça dès qu'il pourra."
		sortie=4 # bugreport : soucis avec le mv qui suit ca marche pas les ..
		;;
	      esac
	    if [[ $interactif = 0 ]]
	      then
		mv -v $dos $HOME/Scans/$serie/$chapitre
	      else
		echo -en "          \033[1m Déplacer $dos dans $HOME/Scans/$serie/$chapitre ? [O/n] \n ==> \033[0m"
		read -n 1 reponse
		case $reponse in
		  n | N )
		    echo -en "\033[1m Veuillez entrez le chemin complet de destination. [$HOME/nimautodl] \n ==> \033[0m"
		    read -r reponse
		    [[ $reponse != "" ]] && mv -v $dos $reponse
		    ;;
		  * )
		    mv -v $dos $HOME/Scans/$serie/$chapitre
		    ;;
		  esac
	      fi
	  done
      done
    cd /tmp/autodl
  fi

if [[ $(ls | grep -v autodl.stop | wc -l) -gt 0 ]]
  then
    mkdir -pv $HOME/nimautodl
    mv -v $(ls | grep -v autodl.stop) $HOME/nimautodl
  fi

[[ $quick = 0 ]] && verification_manque_chapitre

rm -v /tmp/autodl/autodl.stop

for DOS in /tmp/autodl $HOME/nimautodl
  do
    if [[ -d $DOS ]]
      then
	if [[ $(ls $DOS | wc -l) = 0 ]]
	  then
	    rmdir -v $DOS
	  else
	    echo -e "\033[5;31m Il reste des fichiers dans $DOS :\033[0m"
	    ls -A $DOS
	  fi
      fi
  done

IFS=$OLDIFS
exit $sortie
