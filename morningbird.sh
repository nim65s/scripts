#! /bin/bash

VOLINIT=20
VOLMAX=40
TIMEINC=1
VOLINC=1
PLAYER=amarok

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
    dcop amarok player stop
    dcop amarok playlist clearPlaylist
    dcop amarok player enableRandomMode false
    dcop amarok player enableRepeatPlaylist false
    dcop amarok playlistbrowser loadPlaylist Reveil
    dcop amarok player setVolume $VOLINIT
    dcop amarok player play
    for(( vol=$VOLINIT; vol < $VOLMAX; vol++ ))
	do
	    sleep $TIMEINC
	    dcop amarok player setVolumeRelative $VOLINC
	done
    until [ `dcop amarok player isPlaying` = false ]
      do
	sleep 120
      done
    dcop amarok player stop
    dcop amarok playlist clearPlaylist
    dcop amarok player enableRandomMode true
    dcop amarok playlistbrowser loadPlaylist Toute\ la\ collection
  fi

#######	TODO
#	-Verifier si awesome ou kdm, agir sur les variables en fonction
#	-Zenity, of course

exit 0
