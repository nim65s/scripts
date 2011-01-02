#!/bin/bash
#ICS="http://bde.enseeiht.fr/~saurelg/edt.ics"
MIN=78
MIN2=23
MIN3=18
MIN4=15
CMD="$HOME/scripts/morningbird.sh"
CMD2="mpc crop; DISPLAY=:0.1 notify-send -t 20000 '<br/><br/><br/><br/>            Bouge Toi !            <br/><br/><br/><br/>'"
CMD3="mpc stop; DISPLAY=:0.1 notify-send -u urgent -t 20000 '<br/><br/><br/><br/>            DÉGAGE !            <br/><br/><br/><br/>'"
CMD4="crontab -l | egrep -v 'morningbird|notify-send' | crontab -"
DAEMON="cron"

[[ -n "$DISPLAY" ]] || export DISPLAY:=0.1

if [[ "$(date +%H)" -ge 16 ]]
then
	SDATE="$(date -d tomorrow +%Y-%m-%d)"
else
	SDATE="$(date +%Y-%m-%d)"
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
			echo "                          ( défaut : aujourd'hui s'il est moins de 16h, demain sinon )"
			echo " Configuration :"
			echo "                 Pour l'instant, il vous faut éditer les huit premières variables de ce fichier."
			echo "                 'ICS' : adresse du .ics à télécharger"
			echo "                 'MIN', 'MIN2' et 'MIN3' : le nombre de minutes entre l'execution de la commande 'CMD', 'CMD2' et 'CMD3' et l'heure de début de votre emploi du temps"
			echo "                                           ce nombre ne peut exceder une journée moins votre décalage horaire ( donc en UTC +0200, c'est 1320 max... )"
			echo "                 'CMD', 'CMD2' et 'CMD3' : Commandes à executer à ces heures"
			echo "                 'DAEMON' : utilitaire qui execute vos 'CMD' à l'heure H-'MIN' : cron ou kalarm"
			exit 1
			;;
	esac
done

cd $HOME/scripts/textfiles

if [[ ! -e edt-du-jour.txt || $UPDATE == 1  || "$(date -d $(head -n 1 edt-du-jour.txt) +%s)" -lt "$(date -d $SDATE +%s)" ]]
then

#wget -O edt.ics $ICS

sed 's/\r//g' edt.ics > edt

sed -i "1,3d;
s/[\]n/\n/g;
/END:VCALENDAR/d;
s/END:VEVENT/----------------------------------/;
s/BEGIN:VEVENT//;
/LOCATION/d;
s/DESCRIPTION://;
s/SUMMARY://;
/^$/d" edt

echo $SDATE > edt-du-jour.txt
echo '----------------------------------' >> edt-du-jour.txt

while read line
do
	DEB="`echo $line | cut -d":" -f 1`"
	if [[ "$DEB" == "DTSTART" || $DEB == "DTEND" ]]
	then
		echo $(date -d "$(echo $line | cut -d":" -f 2 | sed "s/\([0-9][0-9][0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\)T\([0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\)Z/\1\/\2\/\3 \4:\5:\6Z/")" +%k:%M) >> edt-du-jour.txt
	else
		echo $line >> edt-du-jour.txt
	fi
done < edt

rm edt.ics edt

sed -i "/^$/d" edt-du-jour.txt

fi

[[ "$NOTIFY" == 1 ]] && notify-send -t 15000 "`cat edt-du-jour.txt`" || cat edt-du-jour.txt

if [[ "$ALARM" == 1 ]]
then
	HEURE="$(sed "/^[^0-9]/d" edt-du-jour.txt | sort -n | head -n 1)"
	if [[ "$DAEMON" == "kalarm" ]]
	then
		DATE="$(date -d "$SDATE $HEURE +01:$MIN" +"%Y-%m-%d-%H:%M")"
		DATE="$(date -d "$SDATE $HEURE +01:$MIN2" +"%Y-%m-%d-%H:%M")"
		DATE="$(date -d "$SDATE $HEURE +01:$MIN3" +"%Y-%m-%d-%H:%M")"
		kalarm -t $DATE -e $CMD
		kalarm -t $DATE2 -e $CMD2
		kalarm -t $DATE3 -e $CMD3
		[[ "$NOTIFY" == 1 ]] && notify-send -t 15000 "k-alarme @ $DATE" || echo "k-alarm @ $DATE"
	elif [[ "$DAEMON" == "at" ]]
	then
		echo "TODO : le 'at', marche pas sur mon pc -_-' "
	elif [[ "$DAEMON" == "cron" ]]
	then
			FICHIERTEMP=$(mktemp)
			DATE="$(date -d "$SDATE $HEURE +01:$MIN" +'%M %H %d %m *')"
			DATE2="$(date -d "$SDATE $HEURE +01:$MIN2" +'%M %H %d %m *')"
			DATE3="$(date -d "$SDATE $HEURE +01:$MIN3" +'%M %H %d %m *')"
			DATE4="$(date -d "$SDATE $HEURE +01:$MIN4" +'%M %H %d %m *')"
			echo "$DATE $CMD" > $FICHIERTEMP
			echo "$DATE2 $CMD2" >> $FICHIERTEMP
			echo "$DATE3 $CMD3" >> $FICHIERTEMP
			echo "$DATE4 $CMD4" >> $FICHIERTEMP
			crontab -l >> $FICHIERTEMP
			crontab $FICHIERTEMP
			rm $FICHIERTEMP
			[[ "$NOTIFY" == 1 ]] && notify-send -t 15000 "$(crontab -l)" || crontab -l
	fi
fi

exit 0
