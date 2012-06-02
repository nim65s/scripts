#!/bin/bash

STATUS=false
PULL=false
COMMIT=false
PUSH=false

git=(N7 dotfiles scripts CV JE gdf net7/bots/pipobot)
[[ $(hostname) == "totoro" ]] && git=(${git[*]} AOC_LaTeX)
hg=(net7/admin net7/bots/pipobot-modules net7/doc net7/docs net7/portail net7/scripts_live)

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

for d in ${hg[*]}
do
    if [[ -d ~/$d ]]
    then
        cd ~/$d
        echo -e "\t\t\033[1;32m hg : $d \033[m"
        $STATUS && hg st
        $PULL && hg pull -u
        $COMMIT && hg ci
        $PUSH && hg push
    fi
done
