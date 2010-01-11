#! /bin/bash

VOLINIT=30
VOLMAX=60
TIMEINC=1
VOLINC=1
PLAYER=mpd

ENMARCHE=`ps -ef | grep $PLAYER | grep -v grep | wc -l`

if [ $ENMARCHE = 0 ]
  then
    $PLAYER
  fi

export DISPLAY=:0.0

if [ $PLAYER = mpd ]
  then
    mpc clear
    mpc repeat off
    mpc random off
    mpc load Reveil2
    mpc volume $VOLINIT
    mpc play
    for(( vol=$VOLINIT; vol < $VOLMAX; vol++ ))
	do
	    sleep $TIMEINC
	    mpc volume +$VOLINC
	done
  elif [ $PLAYER = amarok ]
  then
    DCOPSERVER=`cat $HOME/.DCOPserver_animal_\:0 | grep local`
    dcop amarok player stop
#    sleep 1
    until `dcop amarok player isPlaying`
      do
#	dcop amarok playlist togglePlaylist
	dcop amarok playlist clearPlaylist
	dcop amarok player enableRandomMode false
	dcop amarok player enableRepeatPlaylist false
	dcop amarok player setVolume $VOLINIT
        dcop amarok playlistbrowser loadPlaylist "Reveil"
#	sleep 1
      done
    for(( vol=$VOLINIT; vol < $VOLMAX; vol++ ))
	do
	    sleep $TIMEINC
	    dcop amarok player setVolumeRelative $VOLINC
	done
    until [ `dcop amarok player isPlaying` = false ]
      do
	sleep 180
      done
    dcop amarok playlist clearPlaylist
    dcop amarok player enableRandomMode true
    dcop amarok playlistbrowser loadPlaylist Toute\ la\ collection
    sleep 1
    dcop amarok player stop
  fi

#######	TODO
#	-Verifier si awesome ou kdm, agir sur les variables en fonction
#	-Zenity, of course

exit 0
