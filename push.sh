#!/bin/bash

git=(N7 dotfiles scripts CV JE gdf)
[[ $(hostname) == "totoro" ]] && git=$(${git[*]} AOC_LaTeX)
hg=(net7/admin net7/botnet7-ng net7/doc net7/docs net7/pipo-parici net7/portail net7/scripts_live)

for d in ${git[*]} 
do
    cd ~/$d
    echo -e "\t\t\033[1;32m git : $d \033[m"
    pwd
    git pull
    git commit -a
    git push
done

#for d in ${hg[*]}
#do
#    cd ~/$d
#    echo -e "\t\t033[1;32m hg : $d 033[m"
#    pwd
#    hg pull
#    hg commit
#    hg push
#done
