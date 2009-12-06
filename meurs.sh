#!/bin/bash

NOMBRE=`ps -ef | grep -v grep | grep -v meurs | grep $1 | sed 's/  */ /g' | cut --delimiter=" " -f 2 | wc -l`
case $NOMBRE in
	0)
		echo "pas de processus... fin du script";
		;;
	1)
		kill `ps -ef | grep -v grep | grep -v meurs | grep $1 | sed 's/  */ /g' | cut --delimiter=" " -f 2` && echo $1 est mort. RIP.
		;;
	*)
		echo $NOMBRE processus contenant $1 trouvés :
		ps -ef | grep -v grep | grep -v meurs | grep $1
		echo -en "          \033[1m[Sortir/Kill] ?\033[0m"
		read reponse
		case $reponse in
			k* | K*)
				for ATUER in `ps -ef | grep -v grep | grep -v meurs | grep $1 | sed 's/  */ /g' | cut --delimiter=" " -f 2`
					do
						kill $ATUER && echo processus $ATUER mort 
					done
				;;
			*)
				echo "OK, on sort.";
				;;
			esac
		;;
	esac
NOMBRE=`ps -ef | grep -v grep | grep -v meurs | grep $1 | sed 's/  */ /g' | cut --delimiter=" " -f 2 | wc -l`
case $NOMBRE in
	0)
		;;
	1)
		echo -en "          \033[1m$1 pas mort. Sortir/Kill] ?\033[0m"
		read reponse
		case $reponse in
			k* | K*)
				kill -9 `ps -ef | grep -v grep | grep -v meurs | grep $1 | sed 's/  */ /g' | cut --delimiter=" " -f 2` && echo $1 est mort 9 fois. RIP.
				;;
			*)
				echo "OK, on sort.";
				;;
			esac
		;;
	*)
		echo $NOMBRE processus contenant $1 trouvés :
		ps -ef | grep -v grep | grep -v meurs | grep $1
		for ATUER in `ps -ef | grep -v grep | grep -v meurs | grep $1 | sed 's/  */ /g' | cut --delimiter=" " -f 2`
			do
				kill -9 $ATUER && echo processus $ATUER mort 9 fois
			done
		;;
	esac


exit 0
