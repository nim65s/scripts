#!/bin/bash

# Simple version was:
# while read repo
# do ( cd $repo && git pull && [[ -f .gitmodules ]] && git submodule foreach git pull || true ; git status) &
# done
#
# wait

MAINTEMP=$(mktemp)

while read repo ; do
    (
        TEMP=$(mktemp)
        echo $TEMP >> $MAINTEMP
        echo > $TEMP
        echo $repo >> $TEMP
        ( cd $repo && git pull --rebase && [[ -f .gitmodules ]] && git submodule foreach git pull || true ; git status) 2>&1 >> $TEMP
        sed -i '/up[- ]to[- ]date.$/d;/^nothing to commit/d;/^# On branch master/d;/^Entering/d' $TEMP
    ) &
done < ~/.gitrepos

wait

while read temp ; do
    [[ $(wc -l $temp | cut -d' ' -f1) -gt 2 ]] && cat $temp
    rm $temp
done < $MAINTEMP

rm $MAINTEMP
