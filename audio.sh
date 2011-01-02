#! /bin/bash
# script de gestion de l'audio
player=mpd
server=oss

[[ -e $HOME/.zikrc ]] && source $HOME/.zikrc

add_random()
{
		mpc listall | sed -n $((RANDOM % $(mpc stats | grep Songs | awk '{print $2}')+1))p | mpc add
}

case $1 in
		+) # volume up
				if [[ "$server" == "oss" ]]
				then 
						ossmix vmix0-outvol -- +2
				fi
				[[ "$WM" == "awesome" ]] && echo "volwidget:set_value($(ossmix vmix0-outvol | cut -d' ' -f 10)-15)" | awesome-client
				#echo "volwidget:set_value($(ossmix vmix0-outvol | cut -d' ' -f 10)-15)" | awesome-client
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
				fi
				[[ "$WM" == "awesome" ]] && echo "volwidget:set_value($(ossmix vmix0-outvol | cut -d' ' -f 10)-15)" | awesome-client
				#echo "volwidget:set_value($(ossmix vmix0-outvol | cut -d' ' -f 10)-15)" | awesome-client
				;;
		p-)
				if [[ "$player" == "mpd" ]]
				then
						mpc volume -2
				fi
				;;
		m) # volume mute
				if [[ "$server" == "oss" ]]
				then
						if [[ "$(ossmix misc.front-mute | cut -d" " -f 10)" == "ON" ]]
						then
								ossmix misc.front-mute OFF
								[[ "$WM" == "awesome" ]] && echo "spkricone.image = image(beautiful.spkr_icon)" | awesome-client
						else
								ossmix misc.front-mute ON
								[[ "$WM" == "awesome" ]] && echo "spkricone.image = image(beautiful.mute_icon)" | awesome-client
						fi
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
						[[ "$WM" == "awesome" ]] && echo "mpdmode.text ='C'" | awesome-client
						mpc play
						mpc consume on
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
		z)
				if [[ "$player" == "mpd" ]]
				then
						UPPER=$(mpc playlist | wc -l)
						for X in `seq 1 $UPPER`
						do
								RANFROM=$RANDOM
								RANTO=$RANDOM
								let "RANFROM %= $UPPER"
								let "RANFROM += 1"
								let "RANTO %= $UPPER"
								let "RANTO += 1"
								mpc move $RANFROM $RANTO
						done
				fi
				;;
		*) # help
				echo " Nim's Zik controler "
				echo " usage : zik [+|-|m|t|s|n|nn|nnn|r|p|ar|z]"
				echo "     + : raise volume"
				echo "    p+ : raise player's volume"
				echo "     - : lower volume"
				echo "    p- : lower player's volume"
				echo "     m : mute volume"
				echo "     t : toggle play/pause"
				echo "     s : stop music"
				echo "     n : play the next song"
				echo "    nn : change the next song"
				echo "   nnn : change the sont after the next one"
				echo "     r : enter in Nim's random mode"
				echo "     p : play the previous song"
				echo "    ar : add a random song from the database"
				echo "     z : shuffle the current playlist"
				echo "     * : print this help"
				;;
esac

exit 0
				
