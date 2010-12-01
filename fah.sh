#!/bin/bash

# ne pas oublier d'ajouter ALL-NOPASSWD: /etc/rc.d/folding* pour l'utilisateur
cd /etc/rc.d/

case $1 in
		start)
				sudo ./foldingathome-smp start
				sudo ./foldingathome-gpu start
				;;
		stop)
				sudo ./foldingathome-smp stop
				sudo ./foldingathome-gpu stop
				;;
		restart)
				sudo ./foldingathome-smp restart
				sudo ./foldingathome-gpu restart
				;;
		ssta)
				sudo ./foldingathome-smp start
				;;
		ssto)
				sudo ./foldingathome-smp stop
				;;
		gsta)
				sudo ./foldingathome-gpu start
				;;
		gsto)
				sudo ./foldingathome-gpu stop
				;;
		awesome)
				if [[ -f /var/run/daemons/foldingathome-gpu ]]
				then
						echo "fahwidget.bg = beautiful.bg_urgent" | awesome-client
						sudo ./foldingathome-smp stop
						sudo ./foldingathome-gpu stop
				else
						echo "fahwidget.bg = beautiful.bg_normal" | awesome-client
						sudo ./foldingathome-smp start
						sudo ./foldingathome-gpu start
				fi
				;;
		notify)
				notify-send $([[ -f /var/run/daemons/foldingathome-gpu ]] && echo GPU_:_RUNNING || echo GPU_:_STOPPED) "$(cat /opt/fah-gpu/alpha/unitinfo.txt)"
				notify-send $([[ -f /var/run/daemons/foldingathome-smp ]] && echo SMP_:_RUNNING || echo SMP_:_STOPPED) "$(cat /opt/fah-smp/unitinfo.txt)"
				[[ -f /var/run/daemons/foldingathome-gpu || -f /var/run/daemons/foldingathome-smp ]] && BG='normal' || BG='urgent'
				echo "fahwidget.bg = beautiful.bg_$BG" | awesome-client
				;;
		*)
				echo "usage : start | stop | restart | ssta | ssto | gsta | gsto | awesome | notify"
				;;
esac

exit
