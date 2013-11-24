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
        ( cd $repo && git pull --rebase 2>&1 && [[ -f .gitmodules ]] && git submodule foreach git pull || true ; git status) >> $TEMP
        sed -i '/up[- ]to[- ]date.$/d;/^nothing to commit/d;/^# On branch /d;/^Entering/d;/^ControlSocket/d' $TEMP
        sed -i '/^# Sur la branche/d;/^rien à valider, la copie de travail est propre/d;/^La branche courante master est à jour.$/d' $TEMP
        sed -i '/mise à jour en avance rapide sur/d;/^Premièrement, retour de head pour rejouer votre travail par-dessus.../d' $TEMP
    ) &
done < ~/.gitrepos

wait

while read temp ; do
    [[ $(wc -l $temp | cut -d' ' -f1) -gt 2 ]] && cat $temp
    rm $temp
done < $MAINTEMP

rm $MAINTEMP
