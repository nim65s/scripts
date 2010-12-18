#! /bin/bash
# script de gestion de l'audio
player=mpd
server=oss

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
				#[[ "$WM" == "awesome" ]] && echo "volwidget:set_value($(ossmix vmix0-outvol | cut -d' ' -f 10)-15)" | awesome-client
				echo "volwidget:set_value($(ossmix vmix0-outvol | cut -d' ' -f 10)-15)" | awesome-client
				;;
		-) # volume down
				if [[ "$server" == "oss" ]]
				then 
						ossmix vmix0-outvol -- -2
				fi
				#[[ "$WM" == "awesome" ]] && echo "volwidget:set_value($(ossmix vmix0-outvol | cut -d' ' -f 10)-15)" | awesome-client
				echo "volwidget:set_value($(ossmix vmix0-outvol | cut -d' ' -f 10)-15)" | awesome-client
				;;
		m) # volume mute
				if [[ "$server" == "oss" ]]
				then
						if [[ "$(ossmix misc.front-mute | cut -d" " -f 10)" == "ON" ]]
						then
								ossmix misc.front-mute OFF
								echo "spkricone.image = image(beautiful.spkr_icon)" | awesome-client
						else
								ossmix misc.front-mute ON
								echo "spkricone.image = image(beautiful.mute_icon)" | awesome-client
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
							#	if [[ "$(mpc playlist | wc -l)" == "2" ]]
						#		then
						#				add_random
						#		fi
						else
								mpc next
						fi
						#mpc next
				fi
				;;
		n2) # change the next song
				if [[ "$player" == "mpd" ]]
				then
						mpc del 2
						add_random
				fi
				;;
		n3) # change the the song after the next
				if [[ "$player" == "mpd" ]]
				then
						mpc del 3
						add_random
				fi
				;;
		r) # enter in Nim's Random mode
				if [[ "$player" == "mpd" ]]
				then
						mpc consume on
						mpc crop
						add_random
						add_random
						echo "mpdmode.text ='C'" | awesome-client
				fi

				;;
		p) # return to the beginning of the current song or goto the previous song
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
esac

exit 0
				
