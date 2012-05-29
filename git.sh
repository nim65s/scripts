#!/bin/bash

STATUS=false
PULL=false
COMMIT=false
PUSH=false

git=(N7 dotfiles scripts CV JE gdf)
[[ $(hostname) == "totoro" ]] && git=(${git[*]} AOC_LaTeX)
hg=(net7/admin net7/botnet7-ng net7/doc net7/docs net7/pipo-parici net7/portail net7/scripts_live)

if [[ "$1" == "status" ]]
then
    STATUS=true
fi

if [[ "$1" == "pull" ]]
then
    PULL=true
fi

if [[ "$1" == "commit" ]]
then
    PULL=true
    COMMIT=true
fi

if [[ "$1" == "push" ]]
then
    PULL=true
    COMMIT=true
    PUSH=true
fi

for d in ${git[*]} 
do
    if [[ -d ~/$d ]]
    then
        cd ~/$d
        echo -e "\t\t\033[1;32m git : $d \033[m"
        $STATUS && git status
        $PULL && git pull
        $COMMIT && git commit -a
        $PUSH && git push
    fi
done

# TODO: auth HG
#for d in ${hg[*]}
#do
#    cd ~/$d
#    echo -e "\t\t033[1;32m hg : $d 033[m"
#    pwd
#    hg pull
#    hg commit
#    hg push
#done
