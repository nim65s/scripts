#!/bin/bash

#ne pas oublier d'ajouter ALL=NOPASSWD: /etc/rc.d/folding* pour l'utilisateur choisi
cd /etc/rc.d/

case $1 in
  start)
#    sudo ./foldingathome-gpu start
    sudo ./foldingathome-smp start
    ;;
  stop)
#    sudo ./foldingathome-gpu stop
    sudo ./foldingathome-smp stop
    ;;
  restart)
#    sudo ./foldingathome-gpu restart
    sudo ./foldingathome-smp restart
    ;;
  awesome)
    if [[ "$(pidof -o %PPID /opt/fah-smp/fah6)" != "" ]]
      then
	echo "fahwidget.image = image(\"/home/nim/.config/awesome/fahstop.png\")" | awesome-client
#	echo "fahgpuwidget:set_color(beautiful.bg_urgent)" | awesome-client
	echo "fahsmpwidget:set_color(beautiful.bg_urgent)" | awesome-client
	$0 stop
      else
	echo "fahwidget.image = image(\"/home/nim/.config/awesome/fahrun.gif\")" | awesome-client
#	echo "fahgpuwidget:set_color(beautiful.bg_focus)" | awesome-client
	echo "fahsmpwidget:set_color(beautiful.bg_focus)" | awesome-client
	$0 start
      fi
    ;;
  *)
     echo "usage : start | stop | restart | awesome"
     ;;
esac

exit
