#!/bin/bash

##recherche des derniers scans déjà lus
declare -a SCANS
declare -a LAST
SCANS=( Naruto OnePiece )
for mang in ${SCANS[*]}
  do
    LAST=( ${LAST[*]} `ls $HOME/Scans/$mang | sort -g | tail -n 1` )
  done

#affichage
for((i=0;i<${#SCANS[*]};i++))
  do
    echo ${SCANS[$i]} : ${LAST[$i]}
  done

##recherche des nouveaux
mkdir NIMAUTODL
cd NIMAUTODL
wget http://www.scantrad.fr/rss/

NITEM=`grep '<item>' index.html | wc -l`

#test par la date
if [ "scantrad:`grep pubDate index.html | tail -n 1 | sed 's/[ \t]*<pubDate>//' | sed 's/<[/]pubDate>//'`" == "`head -n 1 $HOME/scripts/autodl.txt`" ]
  then
    echo pas de mises à jour sur http://www.scantrad.fr/rss/
  else
    echo mises à jours disponibles !
    FICHIER=`mktemp`
    if [ -e $HOME/scripts/autodl.txt ]
      then
        nouvelledate="`grep pubDate index.html | tail -n 1 | sed 's/[ \t]*<pubDate>//' | sed 's/<[/]pubDate>//'`"
        echo $nouvelledate
	echo "scantrad:" >> $HOME/scripts/autodl.txt
        sed "s/scantrad:[a-zA-Z0-9 ,:+]*/scantrad:$nouvelledate/" $HOME/scripts/autodl.txt | sort | uniq > $FICHIER
	mv $FICHIER $HOME/scripts/autodl.txt
      else # dans ce cas, head bug avant que ce code soit executé.... peut etre toucher le fichier en question et pas mettre de else ?
        touch $HOME/scripts/autodl.txt
#        echo "scantrad:`grep pubDate index.html | tail -n 1 | sed 's/[ \t]*<pubDate>//' | sed 's/<[/]pubDate>//'`" >> $HOME/scripts/autodl.txt
      fi
  fi

#vérification de chaque série
grep '<title>Naruto' index.html



rm index.html
cd ..
rmdir NIMAUTODL







exit
