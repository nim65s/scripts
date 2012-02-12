#!/bin/bash

STATUS=/bin/false
PULL=/bin/false
COMMIT=/bin/false
PUSH=/bin/false

git=(N7 dotfiles scripts CV JE gdf)
[[ $(hostname) == "totoro" ]] && git=(${git[*]} AOC_LaTeX)
hg=(net7/admin net7/botnet7-ng net7/doc net7/docs net7/pipo-parici net7/portail net7/scripts_live)

if [[ "$1" == "status" ]]
then
    STATUS=/bin/true
fi

if [[ "$1" == "pull" ]]
then
    PULL=/bin/true
fi

if [[ "$1" == "commit" ]]
then
    PULL=/bin/true
    COMMIT=/bin/true
fi

if [[ "$1" == "push" ]]
then
    PULL=/bin/true
    COMMIT=/bin/true
    PUSH=/bin/true
fi

for d in ${git[*]} 
do
    cd ~/$d
    echo -e "\t\t\033[1;32m git : $d \033[m"
    $STATUS && git status
    $PULL && git pull
    $COMMIT && git commit -a
    $PUSH && git push
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
