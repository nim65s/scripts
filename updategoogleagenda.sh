#!/bin/bash
# script qui ajoute le votre prochaine journée dans un .ics à google agenda
ICS="http://edt.enseeiht.fr/webpubetu/g80.ics"
USER="edtn7"
PASSWORD="edtn7"

if [[ "$(date +%H)" -ge 16 ]]
then
	SDATE="$(date -d tomorrow +%Y%m%d)"
else
	SDATE="$(date +%Y%m%d)"
fi

cd $HOME/www_public
wget --user=$USER --password=$PASSWORD $ICS
sed 's/\x0D$//' g80.ics > g80

echo "BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Apple Inc.//iCal 4.0.3//EN
BEGIN:VEVENT" > edt.ics

afficher=0
while read line
do
		if [[ "`echo $line | cut -d":" -f 1`" == "DTSTART" ]]
		then
				if [[ "`echo $line | cut -d":" -f 2 | cut -d"T" -f 1`" == "$SDATE" ]]
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
done < g80

rm g80 g80.ics

sed -i "$(wc -l edt.ics | cut -d" " -f 1)d" edt.ics

echo "END:VCALENDAR" >> edt.ics

exit
