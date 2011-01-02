#!/bin/bash
ICS="http://edt.enseeiht.fr/webpubetu/g80.ics"
USER="edtn7"
PASSWORD="edtn7"

[[ `hostname` == 'animal' ]] && cd $HOME/scripts/textfiles || cd $HOME/www_public

if [[ "$(date +%H)" -ge 16 ]]
then
	SDATE="$(date -d tomorrow +%Y%m%d)"
else
	SDATE="$(date +%Y%m%d)"
fi

wget --user=$USER --password=$PASSWORD -O net.ics $ICS
sed 's/\x0D$//' net.ics > ics
sed -i 's/[\]n/\n\r/g' ics

parse_calendar()
{

echo "BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Apple Inc.//iCal 4.0.3//EN
BEGIN:VEVENT" > edt.ics

afficher=0
while read line
do
		if [[ "`echo $line | cut -d":" -f 1`" == "DTSTART" ]]
		then
				if [[ "`echo $line | cut -d":" -f 2 | cut -d"T" -f 1`" == "$1" ]]
				then
						afficher=1
				else
						afficher=0
				fi
		fi
		if [[ $afficher == 1 ]]
		then
				echo $line >> edt.ics
		fi
done < ics

rm ics net.ics

sed -i "$(wc -l edt.ics | cut -d" " -f 1)d;/UID/d;/CATEGORIES/d" edt.ics

echo "END:VCALENDAR" >> edt.ics

}

parse_calendar $SDATE
if [[ $( wc -l edt.ics | cut -d' ' -f1) -lt 5 ]]
then
		COMPTEUR=1
		while [[ $(wc -l edt.ics | cut -d' ' -f1) -lt 5 ]] && [[ "$COMPTEUR" -lt 15 ]]
		do
				SDATE=$(date -d "$SDATE + 1 day" +%Y%m%d)
				parse_calendar $SDATE
				let "COMPTEUR += 1"
		done

fi

exit
