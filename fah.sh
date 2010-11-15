#!/bin/bash

# ne pas oublier d'ajouter ALL-NOPASSWD: /etc/rc.d/folding* pour l'utilisateur
cd /etc/rc.d/

case $1 in
	start)
		sudo ./foldingathome-smp start
		;;
	stop)
		sudo ./foldingathome-smp stop
		;;
	restart)
		sudo ./foldingathome-smp restart
		;;
	awesome)
		if [[ "$(pidof -o %PPID /opt/fah-smp/fah6)" != "" ]]
		then
			echo "fahwidget.bg = beautiful.bg_urgent" | awesome-client
			$0 stop
		else
			echo "fahwidget.bg = beautiful.bg_normal" | awesome-client
			$0 start
		fi
		;;
	notify)
		notify-send "$(cat /opt/fah-smp/unitinfo.txt)"
		;;
	*)
		echo "usage : start | stop | restart | awesome | notify"
		;;
esac

exit
