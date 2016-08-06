#!/bin/bash

if [[ $1 == "sub" ]] ; then
    DIR=$(cut -d: -f2 .git)/hooks
    [[ ! -d $DIR ]] && mkdir -p $DIR
    cd $DIR
    pwd
    [[ -f pre-commit ]] && rm pre-commit
    ln -s ~/scripts/pre-commit.py pre-commit
else
    while read repo ; do
        [[ $repo == -* ]] && continue
        cd $repo
        [[ -f .gitmodules ]] && git submodule foreach ~/scripts/pre-commit-deploy.sh sub | grep -v 'Entrée dans'
        mkdir -p .git/hooks
        cd .git/hooks
        pwd
        [[ -f pre-commit ]] && rm pre-commit
        ln -s ~/scripts/pre-commit.py pre-commit
    done < ~/.gitrepos
fi
