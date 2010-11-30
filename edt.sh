#!/bin/bash
ICS="http://bde.enseeiht.fr/~saurelg/edt.ics"
MIN=78
CMD="$HOME/scripts/morningbird.sh"
DAEMON="cron"

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
			echo " Nim's edt.sh :"
			echo "         Usage :"
			echo "                 ./edt.sh [notify] [update] [alarm]" 
			echo "       Options :"
			echo "                 notify : envoie une notification via 'notify-send'"
			echo "                 update : force la mise à jour, même si le fichier existe et date du jour actuel "
			echo "                 alarm  : programme votre réveil" 
			echo "                 date   : utilise 'yyyymmdd'"
			echo "                          ( défaut : aujourd'hui s'il est moins de 17h, demain sinon )"
			echo " Configuration :"
			echo "                 Pour l'instant, il vous faut éditer les cinq premières variables de ce fichier."
			echo "                 'ICS' : adresse du .ics à télécharger"
			echo "                 'MIN' : Nombre de minutes dont vous avez besoin entre le moement où l'alarme se déclenche et le moment où vous devez entrer en cours"
			echo "                 'CMD' : Commande à executer pour que vous vous réveilliez"
			echo "                 'DAEMON' : utilitaire qui execute votre 'CMD' : cron, at ou kalarm"
			exit 1
			;;
	esac
done

wget $ICS

sed -i "1,3d;
s/[\]n/\n/g;
/END:VCALENDAR/d;
s/END:VEVENT/----------------------------------/;
s/BEGIN:VEVENT//;
/LOCATION/d;
s/DESCRIPTION://;
s/SUMMARY://" edt.ics
sed -i "/^$/d" edt.ics
# le LOCATION peut servir... sais pas
[[ -e edt-du-jour.txt ]] && rm edt-du-jour.txt
afficher=0

while read line
do
	DEB="`echo $line | cut -d":" -f 1`"
	if [[ "$DEB" == "DTSTART" || $DEB == "DTEND" ]]
	then
		echo $(date -d "$(echo $line | cut -d":" -f 2 | sed "s/\([0-9][0-9][0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\)T\([0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\)Z/\1\/\2\/\3 \4:\5:\6Z/")" +%k:%M) >> edt-du-jour.txt
	else
		echo $line >> edt-du-jour.txt
	fi
done < edt.ics

rm edt.ics 

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
		[[ "$NOTIFY" == 1 ]] && notify-send -t 15000 "k-alarme @ $DATE"
	elif [[ "$DAEMON" == "at" ]]
	then
		echo "TODO : le 'at', marche pas sur mon pc -_-' "
	elif [[ "$DAEMON" == "cron" ]]
	then
			DATE="$M $H $(date -d $SDATE +%d) * *"
			echo "$DATE $CMD" | crontab -
			[[ "$NOTIFY" == 1 ]] && notify-send -t 15000 "$(crontab -l)"
	fi
fi

exit 0
