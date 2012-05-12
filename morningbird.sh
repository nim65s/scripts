#! /bin/bash

#valeurs par defaut des variables
VOLINIT=0
VOLMAX=100
TIMEINC=1
VOLINC=1
PLAYER=mpd
TIMEWAIT=180
RAND=false
HOURMIN=06
HOURMAX=12

#modification par fichier de conf
[[ -f $HOME/.morningbirdrc ]] && . $HOME/.morningbirdrc || echo 'Pas de $HOME/.morningbirdrc'

#lecture du mot de passe mpd, s’il y en a un
[[ -f $HOME/.password ]] && . $HOME/.password

#modification par options
while [ $# -ne 0 ]
do
    case $1 in
        volinit=*) VOLINIT=`echo $1 | sed "s/volinit=//"` ;;
        volmax=*) VOLMAX=`echo $1 | sed "s/volmax=//"` ;;
        timeinc=*) TIMEINC=`echo $1 | sed "s/timeinc=//"` ;;
        volinc=*) VOLINC=`echo $1 | sed "s/volinc=//"` ;;
        player=*) PLAYER=`echo $1 | sed "s/player=//"` ;;
        timewait=*) TIMEWAIT=`echo $1 | sed "s/timewait=//"` ;;
        hourmin=*) HOURMIN=`echo $1 | sed "s/hourmin=//"` ;;
        hourmax=*) HOURMAX=`echo $1 | sed "s/hourmax=//"` ;;
        var)
            echo "morningbird variables :"
            echo "VOLINIT=$VOLINIT"
            echo "VOLMAX=$VOLMAX"
            echo "TIMEINC=$TIMEINC"
            echo "VOLINC=$VOLINC"
            echo "PLAYER=$PLAYER"
            echo "TIMEWAIT=$TIMEWAIT"
            echo "HOURMIN=$HOURMIN"
            echo "HOURMAX=$HOURMAX"
            ;;
        *)
            echo "morningbird : usage"
            echo "    morningbird [volinit=P] [volmax=P] [volinc=P] [timeinc=N] [player=S] [timewait=N] [hourmin=H] [hourmax=H] [var]"
            echo "    1 <= P <= 100"
            echo "    N in seconds"
            echo "    H in hours"
            echo "    S = amarokapp | mpd"
            exit 0
            ;;
    esac
    shift
done

HOUR=$(date +%H)
if (( $HOUR > $HOURMAX || $HOUR < $HOURMIN ))
then
    echo 'Ça va pas de lancer le réveil à cette heure ?' > /dev/stderr
    exit 1
fi

alsactl restore
$HOME/scripts/audio.sh um # faut le script... 
$HOME/scripts/audio.sh ums
$HOME/scripts/audio.sh ms

if [[ "$PLAYER" = "mpd" ]]
then
    mpc clear > /dev/null
    mpc repeat off > /dev/null
    $RAND && mpc random on || mpc random off > /dev/null
    mpc consume off > /dev/null
    mpc single off > /dev/null
    mpc load Reveil > /dev/null
    mpc volume $VOLINIT > /dev/null
    mpc enable 1 > /dev/null
    mpc play
    for(( vol=$VOLINIT; vol < $VOLMAX; vol++ ))
    do
        sleep $TIMEINC
        mpc volume +$VOLINC > /dev/null
    done
else
    echo "Pas encore implémenté" > /dev/stderr
fi

exit 0
