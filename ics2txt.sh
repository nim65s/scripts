#!/bin/bash
# bug de l'an 2000 unproof :)
ICS="http://edt.enseeiht.fr/webpubetu/g80.ics"
USER="edtn7"
PASSWORD="edtn7"
MIN=78
CMD="$HOME/scripts/morningbird.sh"
DAEMON="kalarm"

if [[ "$(date +%H)" -ge 16 ]]
then
	SDATE="$(date -d tomorrow +%Y%m%d)"
else
	SDATE="$(date +%Y%m%d)"
fi

NOTIFY=0
UPDATE=0
ALARM=0

for args in $@
do
	case $args in
		n*)
			NOTIFY=1
			;;
		u*)
			UPDATE=1
			;;
		a*)
			ALARM=1
			;;
		d*)
			SDATE="$2"
			shift
			;;
		*)
			echo " Nim's ics2txt :"
			echo "         Usage :"
			echo "                 ./ics2txt.sh [notify] [update] [alarm] [date yyyymmdd]"
			echo "       Options :"
			echo "                 notify : envoie une notification via 'notify-send'"
			echo "                 update : force la mise à jour, même si le fichier existe et date du jour actuel "
			echo "                 alarm  : programme votre réveil" 
			echo "                 date   : utilise 'yyyymmdd'"
			echo "                          ( défaut : aujourd'hui s'il est moins de 17h, demain sinon )"
			echo " Configuration :"
			echo "                 Pour l'instant, il vous faut éditer les cinq premières variables de ce fichier."
			echo "                 'ICS' : adresse du .ics à télécharger"
			echo "                 'USER' & 'PASSWORD' : si nécessaire pour télécharger ce .ics"
			echo "                 'MIN' : Nombre de minutes dont vous avez besoin entre le moement où l'alarme se déclenche et le moment où vous devez entrer en cours"
			echo "                 'CMD' : Commande à executer pour que vous vous réveilliez"
			echo "                 'DAEMON' : utilitaire qui execute votre 'CMD' : cron, at ou kalarm"
			exit 1
			;;
	esac
done


if [[ ! -e edt-du-jour.txt ]] || [[ "$(ls -l --time-style=+%d edt-du-jour.txt | cut -f 6 -d" ")" != "$(date +%d)" ]] || [[ $UPDATE == 1 ]] || [[ "$(ls -l --time-style=+%H edt-du-jour.txt | cut -f 6 -d" ")" -lt 17 && "$(date +%H)" -ge 17 ]] # utiliser date -d $SDATE possible. C'est utile ?
then

[[ -e edt-du-jour.txt ]] && rm edt-du-jour.txt

wget --user=$USER --password=$PASSWORD $ICS

echo "$(wc -l g80.ics | cut -f 1 -d" ") lignes ..."

sed 's/\x0D$//' g80.ics > g80

sed -i "1,2d;
s/[\]n/\n/g;
/CATEGORIES:CELCAT Timetabler (vcal) - 2010_2011/d;
/END:VCALENDAR/d;
/UID/d;
s/END:VEVENT/----------------------------------/;
s/BEGIN:VEVENT//;
/LOCATION/d;
s/DESCRIPTION://;
s/SUMMARY://" g80
sed -i "/^$/d" g80
# le LOCATION peut servir... sais pas
FIN=`wc -l g80| cut -f 1 -d" "`
COURANT=1

echo "plus que $FIN ... "

afficher=0

while read line
do
	 if [[ "`echo $line | cut -d":" -f 1`" == "DTSTART" ]]
	 then
		 if [[ "` echo $line | cut -d":" -f 2 | cut -d"T" -f 1`" == "$SDATE" ]]
		 then
			 afficher=1
		 else
			 afficher=0
		 fi
	 fi
	 if [[ $afficher == 1 ]]
	 then
		 echo $line >> today
	 fi
	 echo -en "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b$COURANT / $FIN ..."
	 let "COURANT += 1"
done < g80

while read line
do
	DEB="`echo $line | cut -d":" -f 1`"
	if [[ "$DEB" == "DTSTART" || $DEB == "DTEND" ]]
	then
		echo $(date -d "$(echo $line | cut -d":" -f 2 | sed "s/\([0-9][0-9][0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\)T\([0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\)Z/\1\/\2\/\3 \4:\5:\6Z/")" +%k:%M) >> edt-du-jour.txt
	else
		echo $line >> edt-du-jour.txt
	fi
done < today

rm g80.ics g80 today

fi


if [[ "$NOTIFY" == 1 ]]
then
	notify-send -t 15000 "`cat edt-du-jour.txt`"
	cat edt-du-jour.txt
fi

if [[ "$ALARM" == 1 ]]
then
	HEURE="$(sed "/^[^0-9]/d" edt-du-jour.txt | sort -n | head -n 1)"
	H="$(echo $HEURE | cut -d":" -f1)"
	M="$(echo $HEURE | cut -d":" -f2)"
	let "DM = MIN % 60"
	let "DH = MIN / 60"
	let "M -= DM"
	[[ $M -lt 0 ]] && let "M += 60" && let "H -= 1"
	let "H -= DH"

	if [[ "$DAEMON" == "kalarm" ]]
	then
		DATE="$(date -d $SDATE +%d)-$H:$M"
		[[ "$ne" != 0 ]] && echo "k-alarme @ $DATE"
		kalarm -t $DATE -e $CMD
	elif [[ "$DAEMON" == "at" ]]
	then
		echo "TODO : le 'at', marche pas sur mon pc -_-' "
	elif [[ "$DAEMON" == "cron" ]]
	then
		echo "TODO : reste plus qu'à trouver où est la crontab, mais là j'ai la flemme^^"
	fi
fi

exit 0
