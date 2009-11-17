#! /bin/bash

VOLINIT=30
VOLMAX=35
TIMEINC=3
VOLINC=1

export DISPLAY=:0.0

if [ ` ps -ef | grep mpd | grep -v grep | wc -l ` = 0 ]
    then
	mpd
    fi

mpc clear
mpc repeat off
mpc random off
mpc load Reveil2
mpc volume $VOLINIT
mpc play

# zenity --question --text="Repasser le volume de mpd à 25% ?" --title="Debout là-dedans ! " --window-icon=/srv/http/favicon.png --width=960 --height=600 --timeout=3600

for(( vol=$VOLINIT; vol < $VOLMAX; vol++ ))
    do
	sleep $TIMEINC
	mpc volume +$VOLINC
    done

# ajouter quelques variables pour faire joli :)
#ou pas
#for(( i=1; i < 4; i++))
#    do
#	sleep 60
#	mpc volume +10
#    done

#######	TODO
#	-Verifier si awesome ou kdm, agir sur les variables en fonction
#	-Zenity, of course
#	-Passer en V1.0
#	-

exit
