#!/bin/bash
#TODO : script à la yaourt pour n'en tuer que quelques uns
# option : d => Défoncer : les tue, sans demander
defonce=0
[[ $1 = "d" ]] && defonce=1 && shift

tous_les_tuer()
  {
    for ATUER in $(ps -ef | grep -v grep | grep -v meurs | grep $1 | sed 's/  */ /g' | cut --delimiter=" " -f 2)
      do
	kill $ATUER && echo processus $ATUER mort
      done
  }

NOMBRE=$(ps -ef | grep -v grep | grep -v meurs | grep $1 | sed 's/  */ /g' | cut --delimiter=" " -f 2 | wc -l)
case $NOMBRE in
  0)
    echo "pas de processus... fin du script";
    ;;
  1)
    kill $(ps -ef | grep -v grep | grep -v meurs | grep $1 | sed 's/  */ /g' | cut --delimiter=" " -f 2) && echo $1 est mort. RIP.
    ;;
  *)
    echo $NOMBRE processus contenant $1 trouvés :
    ps -ef | grep -v grep | grep -v meurs | grep $1
    if [[ $defonce = 1 ]]
      then
	tous les tuer $1
      else
	echo -en "          \033[1m[Sortir/Kill] ?\033[0m"
	read -n 1 reponse
	case $reponse in
	  k* | K*)
	    tous_les_tuer $1
	    ;;
	  *)
	    echo "OK, on sort.";
	    ;;
	  esac
      fi
    ;;
  esac
sleep 3
NOMBRE=$(ps -ef | grep -v grep | grep -v meurs | grep $1 | sed 's/  */ /g' | cut --delimiter=" " -f 2 | wc -l)
case $NOMBRE in
  0)
    ;;
  1)
    if [[ $defonce = 1 ]]
      then
	kill -9 $(ps -ef | grep -v grep | grep -v meurs | grep $1 | sed 's/  */ /g' | cut --delimiter=" " -f 2) && echo $1 est mort 9 fois. RIP.
      else
	echo -en "          \033[1m$1 pas mort. Sortir/Kill] ?\033[0m"
	read -n 1 reponse
	case $reponse in
	  k* | K*)
	    kill -9 $(ps -ef | grep -v grep | grep -v meurs | grep $1 | sed 's/  */ /g' | cut --delimiter=" " -f 2) && echo $1 est mort 9 fois. RIP.
	    ;;
	  *)
	    echo "OK, on sort.";
	    ;;
	  esac
      fi
  *)
    echo $NOMBRE processus contenant $1 trouvés :
    ps -ef | grep -v grep | grep -v meurs | grep $1
    for ATUER in $(ps -ef | grep -v grep | grep -v meurs | grep $1 | sed 's/  */ /g' | cut --delimiter=" " -f 2)
      do
	kill -9 $ATUER && echo processus $ATUER mort 9 fois
      done
    ;;
  esac


exit 0
