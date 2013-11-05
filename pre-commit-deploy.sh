#!/bin/bash

if [[ $1 == "sub" ]] ; then
    cd $(cut -d: -f2 .git)/hooks
    pwd
    ln -s ~/scripts/pre-commit
else
    while read repo ; do
        cd $repo
        [[ -f .gitmodules ]] && git submodule foreach ~/scripts/pre-commit-deploy.sh sub
        cd .git/hooks
        pwd
        ln -s ~/scripts/pre-commit
    done < ~/.gitrepos
fi
