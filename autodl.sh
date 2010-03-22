#!/bin/bash
# TODO : curl plutot que wget dans le cas où plus.php & index.php seraient dépassés
# Options : 
# mettre directement à jour
# 

OLDIFS=$IFS
IFS=$'\n'
declare -a SCANS
declare -a SITES
declare -a ADDRSITES
declare -a DATESSITES
declare -a scantrad
declare -a japanshin
SCANS=( Naruto OnePiece Kenichi )
SITES=( scantrad japanshin )
ADDRSITES=( http://www.scantrad.fr/rss/ http://www.japan-shin.com/ )
DATESSITES=( \<pubDate\> \<td\ width=\"150\"\ bgcolor=\"#333333\"\>\<\em\> ) # TODO : passage des <>\ "# ?
scantrad=( Naruto OnePiece )
japanshin=( Kenichi )
dlscantrad=0
dljapanshin=0
for((i=0;i<${#scantrad[*]};i++))
  do
    declare ${scantrad[$i]}=`ls $HOME/Scans/${scantrad[$i]} | sort -g | tail -n 1`
    echo ${scantrad[$i]} : ${!scantrad[$i]}
  done
kenichi=`ls $HOME/Scans/Kenichi | sort -g | tail -n 1`
echo Kenichi : $kenichi

# TODO cd $HOME sur demande ou pas
touch $HOME/scripts/autodl.txt
mkdir NIMAUTODL
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
	echo "mises à jours disponibles sur ${ADDRSITES[$i]} !"
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
	serie=`echo $titre | sed "s/[ \t0-9]//g"`
	if [[ "$serie" == "${scantrad[0]}" || "$serie" == "${scantrad[1]}" ]]
	  then
	    chapitre=`echo $titre | sed "s/[ a-zA-Z]//g"`
	    if [ $chapitre -gt ${!serie} ]
	      then
		echo "$titre trouvé et plus récent que le dernier chapitre de $serie présent sur le disque (${!serie})"
	      else
		# TODO : déplacer
		dlscantrad=1
		echo "$titre trouvé mais pas plus récent que le dernier chapitre de $serie présent sur le disque (${!serie})"
		wget -nv `echo $line | sed 's/.*<link>//' | sed 's/<.*//'`
	      fi
	  fi
      done < scantrad
#      rm scantrad
  fi

if [ $dlscantrad = 1 ]
  then
    for todl in plus.php*
      do
	wget -nv `grep 'class="telecharger"' $todl | sed 's/.*href="//' | sed 's/".*//'`
	rm $todl
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
		echo "$titre trouvé et plus récent que le dernier chapitre de Kenichi présent sur le disque ($kenichi)"
 		dljapanshin=1
	      else
		echo "$titre trouvé mais pas plus récent que le dernier chapitre de Kenichi présent sur le disque ($kenichi)"
		if [ $dljapanshin = 0 ]
		  then
		    wget -nv `echo $line | cut --delimiter=">" -f 14 | sed 's/<a href="/http:\/\/www.japan-shin.com/'# | sed 's/"//' | sed 's/\&amp;/\&/g'`
		    dljapanshin=1 # TODO
		  fi
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

echo "-!-!-!-!-!-!-!-!-!-!-!-!-!- téléchargements des nouveaux chapitres !!! -!-!-!-!-!-!-!-!-!-!-!-!-!-"

if [[ $dljapanshin = 1 || $dlscantrad = 1 ]]
  then
    for todl in `ls`
      do
	mv ./$todl todl
	echo JE TELECHARGE `grep http://www.megaupload.com todl | sed "s/.*http:\/\/www.megaupload.com/http:\/\/www.megaupload.com/" | sed 's/".*//'` 
	$HOME/scripts/dl.sh `grep http://www.megaupload.com todl | sed "s/.*http:\/\/www.megaupload.com/http:\/\/www.megaupload.com/" | sed 's/".*//'`
      done
    rm todl
    mv * ..
  fi

cd ..
rmdir NIMAUTODL

IFS=$OLDIFS

exit

