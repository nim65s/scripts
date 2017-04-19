#!/bin/bash

# Simple version was:
# while read repo
# do ( cd $repo && git pull && [[ -f .gitmodules ]] && git submodule foreach git pull || true ; git status) &
# done < ~/.gitrepos
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
            git pull --rebase >> $TEMP 2> /dev/null
            if [[ -f .gitmodules ]] ; then
                git submodule update --recursive --remote --rebase --init >> $TEMP 2> /dev/null
                git submodule foreach -q --recursive 'git checkout $(git config -f $toplevel/.gitmodules submodule.$name.branch || echo master)' >> $TEMP 2> /dev/null
            fi
            git status >> $TEMP
            sed -i "/Sur la branche [[:alnum:]_]\{1,\}/d;/Votre branche est à jour avec 'origin\/[[:alnum:]_]\{1,\}'./d" $TEMP
            sed -i "/rien à valider, la copie de travail est propre/d;/^Entrée dans '/d" $TEMP
            sed -i "/La branche courante [[:alnum:]_]\{1,\} est à jour./d;/^Chemin de sous-module '/d" $TEMP
            sed -i "/Current branch [[:alnum:]_]\{1,\} is up to date./d;/^Entering '/d;/Submodule '/d" $TEMP
            sed -i "/# On branch [[:alnum:]_]\{1,\}/d;/nothing to commit (working directory clean)/d" $TEMP
            sed -i "/On branch [[:alnum:]_]\{1,\}/d;/nothing to commit, working directory clean/d" $TEMP
            sed -i "/Votre branche est à jour avec /d;/Déjà à jour./d" $TEMP
            sed -i "/Your branch is up-to-date with /d" $TEMP
            sed -i "/nothing to commit, working tree clean/d" $TEMP
            sed -i "/^$/d" $TEMP

        ) &
    fi
done < ~/.gitrepos

wait

while read temp ; do
    [[ $(wc -l $temp | cut -d' ' -f1) -gt 1 ]] && cat $temp
    rm $temp
done < $MAINTEMP

rm $MAINTEMP
