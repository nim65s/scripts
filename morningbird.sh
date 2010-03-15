#! /bin/bash

#valeurs par defaut des variables
VOLINIT=30
VOLMAX=60
TIMEINC=1
VOLINC=1
PLAYER=amarok
TIMEWAIT=180

#modification par options
while [ $# -ne 0 ]
  do
    case $1 in
      volinit=*)
        VOLINIT=`echo $1 | sed "s/volinit=//"`
        ;;
      volmax=*)
        VOLMAX=`echo $1 | sed "s/volmax=//"`
        ;;
      timeinc=*)
        TIMEINC=`echo $1 | sed "s/timeinc=//"`
        ;;
      volinc=*)
        VOLINC=`echo $1 | sed "s/volinc=//"`
        ;;
      player=*)
        PLAYER=`echo $1 | sed "s/player=//"`
        ;;
      timewait=*)
        TIMEWAIT=`echo $1 | sed "s/timewait=//"`
        ;;
      var)
	echo "morningbird variables :"
	echo "VOLINIT=$VOLINIT"
	echo "VOLMAX=$VOLMAX"
	echo "TIMEINC=$TIMEINC"
	echo "VOLINC=$VOLINC"
	echo "PLAYER=$PLAYER"
	echo "TIMEWAIT=$TIMEWAIT"
	;;
      *)
	echo "morningbird : usage"
	echo "    morningbird [volinit=P] [volmax=P] [volinc=P] [timeinc=N] [player=S] [timewait=N] [var]"
	echo "    1 <= P <= 100"
	echo "    N in seconds"
	echo "    S = amarok | mpd"
	exit 0
	;;
      esac
    shift
  done

ENMARCHE=`ps -ef | grep $PLAYER | grep -v grep | wc -l`
if [ $ENMARCHE = 0 ]
  then
    $PLAYER
  fi

export DISPLAY=:0.0

if [ "$PLAYER" = "mpd" ]
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
  elif [ "$PLAYER" = "amarok" ]
  then
#    DCOPSERVER=`cat $HOME/.DCOPserver_animal_\:0 | grep local`
    dcop amarok player stop
	dcop amarok playlist clearPlaylist
	dcop amarok player enableRandomMode false
	dcop amarok player enableRepeatPlaylist false
	dcop amarok player setVolume $VOLINIT
        dcop amarok playlistbrowser loadPlaylist "Reveil"
    until `dcop amarok player isPlaying`
      do
	sleep 1
      done
    for(( vol=$VOLINIT; vol < $VOLMAX; vol++ ))
	do
	    sleep $TIMEINC
	    dcop amarok player setVolumeRelative $VOLINC
	done
    until [ `dcop amarok player isPlaying` = false ]
      do
	sleep $TIMEWAIT
      done
    dcop amarok playlist clearPlaylist
    dcop amarok player enableRandomMode true
    dcop amarok playlistbrowser loadPlaylist Toute\ la\ collection
    sleep 2
    dcop amarok player stop
  fi

exit 0
