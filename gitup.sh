#!/bin/bash

# Simple version was:
# while read repo
# do ( cd $repo && git pull && [[ -f .gitmodules ]] && git submodule foreach git pull || true ; git status) &
# done
#
# wait

MAINTEMP=$(mktemp)

while read repo ; do
    if [[ $repo == -* ]] ; then
        echo $repo
    else
        (
            TEMP=$(mktemp)
            echo $TEMP >> $MAINTEMP
            echo -e "\033[1;32m $repo \033[0m" >> $TEMP
            cd $repo || exit 1
            git pull --rebase origin master >> $TEMP 2> /dev/null
            if [[ -f .gitmodules ]] ; then
                git submodule init >> $TEMP 2> /dev/null
                git submodule update >> $TEMP 2> /dev/null
                git submodule foreach git checkout master >> $TEMP 2> /dev/null
                git submodule foreach git pull --rebase origin master >> $TEMP 2> /dev/null
            fi
            git status >> $TEMP
            sed -i "/Sur la branche master/d;/Votre branche est à jour avec 'origin\/master'./d" $TEMP
            sed -i "/rien à valider, la copie de travail est propre/d;/^Entrée dans '/d" $TEMP
            sed -i "/La branche courante master est à jour./d;/^Chemin de sous-module '/d" $TEMP
        ) &
    fi
done < ~/.gitrepos

wait

while read temp ; do
    [[ $(wc -l $temp | cut -d' ' -f1) -gt 1 ]] && cat $temp
    rm $temp
done < $MAINTEMP

rm $MAINTEMP
