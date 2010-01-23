#!/bin/bash

for KEN in `ls -bd \[JS\]* | grep -v rar`
  do
    feh -FrSname $KEN
  done

# ancien script... Je sais meme plus a quoi il servait XD
# cd /home/nim/Desktop/
# IFS=$'\n' && if [ -e *enichi*.rar ]
#  then
#   mv *enichi*.rar /media/320/Nimsave/Mes\ mangas/Scans/kenichi/
#  else
#   echo -e "\033[1;31mPas de *enichi*.rar dans /Desktop/"
#   R=1
#  fi
# cd /media/320/Nimsave/Mes\ mangas/Scans/kenichi/
# if [ -e *enichi*.rar ]
#  then
#   IFS=$'\n' && for RAR in `ls *.rar`
#    do
#     unrar x $RAR
#     rm $RAR
#    done
#  else
#   echo -e "\033[1;31mPas de *enichi*.rar dans /Scans/kenichi/"
#   RR=1
#  fi
# if [[ R==1 && RR==1 ]]
#  then
#   echo "Pas de bol :("
#   PS3="Pas de bol. Que faire ?"
#   select reponse in "bouger ces putains de fichiers meme s'ils ont des espaces bordayl !" "Oh ... My fault, sorry x) => I'm escaping..."
#    do
#     if [ $reponse != 1 ]
#      then
#       echo "Fuyez!"
#      break
#     else
#      mv *enichi*.rar /media/320/Nimsave/Mes\ mangas/Scans/kenichi/
#      IFS=$'\n' && for RAR in `ls *.rar`
#       do
#        unrar x $RAR
#        rm $RAR
#       done
#      fi
#     done
#  fi
# echo "fin du script"
# echo
exit
