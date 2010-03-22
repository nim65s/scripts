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
sortie=0

while [ $1 ]
  do
    case $1 in
      l )
	lire=1
	;;
      f )
	force=1
	;;
      o )
	if [ -e $HOME/scripts/autodl.stop ]
	  then
	    rm $HOME/scripts/autodl.stop
	  fi
	;;
      * )
	echo "nimautdl usage : "
	echo '$HOME/scripts/nimautodl.sh [ o ] [ f ] [ l ]'
	echo " options : "
	echo "       o : outrepasse le vérou "
	echo "       f : force la mise à jour sans tenir compte de la date "
	echo "       l : lire puis archiver les mangas téléchargés "
	echo " code de sortie : "
	echo "              0 : le script s'est déroulé sans encombres "
	echo "              1 : vérou présent, rien ne s'est passé "
	echo "              2 : vérou présent sur dl.sh, les fichiers sont téléchargés dans \$HOME/nimdl "
	echo "              3 : mauvais arguments, affichage de l'aide et sortie"
	IFS=$OLDIFS
	exit 3
	;;
      esac
    shift
  done

if [ -e $HOME/scripts/autodl.stop ]
  then
    IFS=$OLDIFS
    exit 1
  else
    touch $HOME/scripts/autodl.stop
  fi 

for((i=0;i<${#scantrad[*]};i++))
  do
    declare ${scantrad[$i]}=`ls $HOME/Scans/${scantrad[$i]} | sort -g | tail -n 1`
    echo ${scantrad[$i]} : ${!scantrad[$i]}
  done
kenichi=`ls $HOME/Scans/Kenichi | sort -g | tail -n 1`
echo Kenichi : $kenichi

if [[ $force = 1 ]]
  then
    rm $HOME/scripts/autodl.txt
  fi
touch $HOME/scripts/autodl.txt
if [ ! -d NIMAUTODL ]
  then
    mkdir NIMAUTODL
  fi
cd NIMAUTODL

for((i=0;i<${#SITES[*]};i++))
  do
    wget -nv ${ADDRSITES[$i]}
    nouvelledate=`grep "${DATESSITES[$i]}" index.html | head -n 1 | sed "s/[ \t]*${DATESSITES[$i]}//" | sed "s/<.*//"`
    if [ "${SITES[$i]}:$nouvelledate" == "`grep ${SITES[$i]} $HOME/scripts/autodl.txt`" ]
      then
	echo "pas de mises à jour sur ${ADDRSITES[$i]}"
	rm index.html
      else
	echo "mises à jours disponibles sur ${ADDRSITES[$i]} !!!"
	echo "Ancienne date : `grep ${SITES[$i]} $HOME/scripts/autodl.txt | sed \"s/${SITES[$i]}://\"`"
	echo "Nouvelle date : $nouvelledate"
	echo "${SITES[$i]}:" >> $HOME/scripts/autodl.txt
	FICHIER=`mktemp`
	sed "s/${SITES[$i]}:.*/${SITES[$i]}:$nouvelledate/" $HOME/scripts/autodl.txt | sort | uniq > $FICHIER
	mv $FICHIER $HOME/scripts/autodl.txt
	mv index.html ${SITES[$i]}
      fi
  done

echo "-------------- analyse de scantrad --------------"

if [ -e scantrad ]
  then
    FICHIER=`mktemp`
    sed -e :a -e "/title>$/N; s/\n[ \t]*//; ta" scantrad | grep '<title>' > $FICHIER
    mv $FICHIER scantrad
    while read line
      do
	titre=`echo $line | sed "s/<title>//" | sed "s/<.*//"`
	serie=`echo $titre | sed "s/[ \t0-9:]//g"`
	if [[ "$serie" == "${scantrad[0]}" || "$serie" == "${scantrad[1]}" || "$serie" == "${scantrad[2]}" ]]
	  then
	    chapitre=`echo $titre | sed "s/[ a-zA-Z:]//g"`
	    if [ $chapitre -gt ${!serie} ]
	      then
		echo "$titre trouvé et plus récent que le dernier chapitre de $serie présent sur le disque (${!serie}) !!!!!!!!!!"
		dlscantrad=1
		wget -nv `echo $line | sed 's/.*<link>//' | sed 's/<.*//'`
	      else
		echo "$titre trouvé mais < ${!serie}"
	      fi
	  fi
      done < scantrad
      rm scantrad
  fi

if [ $dlscantrad = 1 ]
  then
    for todl in plus.php*
      do
	FICHIER=`mktemp`
	grep 'class="telecharger"' $todl | sed 's/.*href="//' | sed 's/".*//' > $FICHIER
	wget -nv -i $FICHIER
	rm $todl $FICHIER
      done
  fi

echo "-------------- analyse de japanshin --------------"

# TODO  : kenichi => $serie

if [ -e japanshin ]
  then
    FICHIER=`mktemp`
    sed "s/<\/td>.*/<\/td>\\\/" japanshin | sed -e :a -e '/\\$/N; s/\\\n[ \t]*//; ta ' | grep '<td width="225" bgcolor="#333333">' > $FICHIER
    mv $FICHIER japanshin
    while read line
      do
	titre=`echo $line | cut --delimiter=">" -f 7 | sed "s/<\/td//"`
	serie=`echo $titre | sed "s/\/Tome//" | sed "s/[/ 0-9]//g"`
	if [ $serie = Kenichi ]
	  then
	    chapitre=`echo $titre | sed "s/[/].*//" | sed "s/[ a-zA-Z/]//g"`
	    if [ $chapitre -gt $kenichi ]
	      then
		echo "$titre trouvé et plus récent que le dernier chapitre de Kenichi présent sur le disque ($kenichi) !!!!!!!!!!"
		dljapanshin=1
		wget -nv `echo $line | cut --delimiter=">" -f 14 | sed 's/<a href="/http:\/\/www.japan-shin.com/'# | sed 's/"//' | sed 's/\&amp;/\&/g'`
	      else
		echo "$titre trouvé mais < ($kenichi)"
	      fi
	  fi
      done < japanshin
    rm japanshin
  fi

if [ $dljapanshin = 1 ]
  then
    for todl in index.php*
      do
	FICHIER=`mktemp`
	grep miroriii $todl | cut --delimiter=">" -f 7 | sed 's/<A href="//' | sed 's/".*//' | sed "s/ /\\\ /g" > $FICHIER
	wget -nv -i $FICHIER
	rm $todl $FICHIER
      done
  fi

if [[ $dljapanshin == 1 || $dlscantrad == 1 ]]
  then
    echo "-!-!-!-!-!-!-!-!-!-!-!-!-!- téléchargements des nouveaux chapitres !!! -!-!-!-!-!-!-!-!-!-!-!-!-!-"
    for todl in `ls`
      do
	mv ./$todl todl
	$HOME/scripts/dl.sh $PWD `grep http://www.megaupload.com todl | sed "s/.*http:\/\/www.megaupload.com/http:\/\/www.megaupload.com/" | sed 's/".*//'`
	if [ $? = 1 ]
	  then
	    echo "ATTENTION ! Le téléchargement a été placé en file d'attente. Les fichiers seront téléchargés dans $HOME/nimdl"
	    sortie=2
	  fi
      done
    rm todl
    echo "-------------- extraction --------------"
    $HOME/scripts/extracteur.sh -r
  fi

if [[ $lire = 1 ]]
  then
    echo "-------------- place à la lecture et à l'archivage --------------"
    dossieralire=( $PWD )
    for dos in nimdl nimautodl
      do
	if [ -d $HOME/$dos ]
	  then
	    dossieralire=( ${dossieralire[*]} $HOME/$dos )
	  fi
      done
    for fold in ${dossieralire[*]}
      do
	cd $fold
	for dos in `ls`
	  do
	    feh -FrSname $dos
	    chapitre=`echo $dos | sed "s/\xf8//" | sed "s/[^0-9]//g"`
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
		serie=faux/chemin/plutot/improbable/a/moins/de/faire/expres
		echo "ATTENTION ! Autodl n'a pas pu déterminer de quelle série il s'agissait pour $dos, il restera donc dans ce dossier, et le déplacement ci-dessous va pas aimer." 
		;;
	      esac
	    mv -v $dos $HOME/Scans/$serie/$chapitre
	  done
      done
    cd ${dossieralire[0]}
  else
    if [ ! -d $HOME/nimautodl ]
      then
	mkdir $HOME/nimautodl
      fi
    if [ `ls | wc -l` -gt 0 ]
      then
	mv * $HOME/nimautodl
      fi
  fi

cd ..
if [ `ls NIMAUTODL | wc -l` = 0 ]
  then
    rmdir NIMAUTODL
  fi

IFS=$OLDIFS

rm $HOME/scripts/autodl.stop

exit $sortie
