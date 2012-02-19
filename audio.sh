#! /bin/bash
# script de gestion de l'audio

. ~/.password

player=mpd
server=alsa
#server=oss
WM=awesome

alarm_playlist_name=Reveil
alarm_volume_init=80
alarm_volume_max=100
alarm_time_inc=1

MUTE_ICON="spkricone.image = image(beautiful.mute_icon)"
SPKR_ICON="spkricone.image = image(beautiful.spkr_icon)"

add_random()
{
    MODULO=$(mpc stats | grep Songs | awk '{print $2}')
    mpc listall | sed -n $((RANDOM % $MODULO+1))p | mpc add
}

case $1 in
    +) # volume up
        if [[ "$server" == "oss" ]]
        then 
            ossmix vmix0-outvol -- +2
            if [[ "$WM" == "awesome" ]] 
            then
                VAL=$(ossmix vmix0-outvol | cut -d' ' -f 10)
                echo "volwidget:set_value($VAL-15)" | awesome-client
            fi
        elif [[ "$server" == "alsa" ]]
        then 
            amixer set Master 3dB+
            amixer set PCM 3dB+
            if [[ "$WM" == "awesome" ]] 
            then
                VAL1=$(amixer get Master | tail -n 1 | cut -d' ' -f 7)
                VAL1=$(echo $VAL1 | sed 's/\[-//;s/\..*//')
                VAL2=$(amixer get PCM | tail -n 1 | cut -d' ' -f 8)
                VAL2=$(echo $VAL2 | sed 's/\[-//;s/\..*//')
                VAL=$((100-$VAL1-$VAL2))
                echo "volwidget:set_value($VAL)" | awesome-client
            fi
        fi
        ;;
    p+) # player's volume up
        if [[ "$player" == "mpd" ]]
        then
            mpc volume +2
        fi
        ;;
    -) # volume down
        if [[ "$server" == "oss" ]]
        then 
            ossmix vmix0-outvol -- -2
            if [[ "$WM" == "awesome" ]] 
            then
                VAL=$(ossmix vmix0-outvol | cut -d' ' -f 10)
                echo "volwidget:set_value($VAL-15)" | awesome-client
            fi
        elif [[ "$server" == "alsa" ]]
        then 
            amixer set Master 3dB-
            amixer set PCM 3dB-
            if [[ "$WM" == "awesome" ]] 
            then
                VAL1=$(amixer get Master | tail -n 1 | cut -d' ' -f 7)
                VAL1=$(echo $VAL1 | sed 's/\[-//;s/\..*//')
                VAL2=$(amixer get PCM | tail -n 1 | cut -d' ' -f 8)
                VAL2=$(echo $VAL1 | sed 's/\[-//;s/\..*//')
                VAL=$((100-$VAL1-$VAL2))
                echo "volwidget:set_value($VAL)" | awesome-client
            fi
        fi
        ;;
    p-)
        if [[ "$player" == "mpd" ]]
        then
            mpc volume -2
        fi
        ;;
    m) # toggle volume mute
        if [[ "$server" == "oss" ]]
        then
            if [[ "$(ossmix misc.front-mute | cut -d" " -f 10)" == "ON" ]]
            then
                ossmix misc.front-mute OFF
                [[ "$WM" == "awesome" ]] && echo $MUTE_ICON | awesome-client
            else
                ossmix misc.front-mute ON
                [[ "$WM" == "awesome" ]] && echo $SPKR_ICON | awesome-client
            fi
        elif [[ "$server" == "alsa" ]]
        then
            if [[ "$(amixer get Master | tail -n 1 | cut -d[ -f 4)" == "on]" ]]
            then
                amixer set Master off
                [[ "$WM" == "awesome" ]] && echo $MUTE_ICON | awesome-client
            else
                amixer set Master on
                [[ "$WM" == "awesome" ]] && echo $SPKR_ICON | awesome-client
            fi
        fi
        ;;
    um) # volume umute
        if [[ "$server" == "oss" ]]
        then
            ossmix misc.front-mute ON
            [[ "$WM" == "awesome" ]] && echo $SPKR_ICON | awesome-client
        elif [[ "$server" == "alsa" ]]
        then
            amixer set Master on
            [[ "$WM" == "awesome" ]] && echo $SPKR_ICON | awesome-client
        fi
        ;;
    t) # play/pause
        if [[ "$player" == "mpd" ]]
        then 
            mpc toggle
        fi
        ;;
    s) # stop
        if [[ "$player" == "mpd" ]]
        then 
            mpc stop
        fi
        ;;
    n) # next song
        if [[ "$player" == "mpd" ]]
        then
            if [[ "$(mpc status | tail -n 1 | awk '{print $9}')" == "on" ]]
            then
                mpc del 0
            else
                mpc next
            fi
        fi
        ;;
    nn) # change the next song
        if [[ "$player" == "mpd" ]]
        then
            mpc del 2
            add_random
        fi
        ;;
    nnn) # change the song after the next
        if [[ "$player" == "mpd" ]]
        then
            mpc del 3
            add_random
        fi
        ;;
    r) # enter in Nim's Random mode
        if [[ "$player" == "mpd" ]]
        then
            [[ "$(mpc playlist | wc -l)" -gt 1 ]] && mpc crop
            add_random
            add_random
            [[ "$WM" == "awesome" ]] && echo "mpdmode.text ='C'"| awesome-client
            mpc play
            mpc consume on
            mpc random off
        fi
        ;;
    p) # play the previous song
        if [[ "$player" == "mpd" ]]
        then 
            mpc prev
        fi
        ;;
    ar) # add a random song from the database
        if [[ "$player" == "mpd" ]]
        then
            add_random
        fi
        ;;
    a) # start your alarm
        if [ "$player" == "mpd" ]]
        then
            mpc clear
            mpc repeat off
            mpc random off
            mpc consume off
            mpc single off
            mpc load $alarm_playlist_name
            mpc volume $alarm_volume_init
            mpc play
            for((vol=$alarm_volume_init;vol < $alarm_volume_max;vol++))
            do
                sleep $alarm_time_inc
                mpc volume +1
            done
        fi
        ;;
    *) # help
        echo " Nim's Zik controler "
        echo " usage : zik [+|-|m|t|s|n|nn|nnn|r|p|ar|a]"
        echo "     + : raise volume"
        echo "    p+ : raise player's volume"
        echo "     - : lower volume"
        echo "    p- : lower player's volume"
        echo "     m : toggle mute volume"
        echo "    um : unmute volume"
        echo "     t : toggle play/pause"
        echo "     s : stop music"
        echo "     n : play the next song"
        echo "    nn : change the next song"
        echo "   nnn : change the sont after the next one"
        echo "     r : enter in Nim's random mode"
        echo "     p : play the previous song"
        echo "    ar : add a random song from the database"
        echo "     a : start your alarm"
        echo "     * : print this help"
        ;;
esac

exit 0
