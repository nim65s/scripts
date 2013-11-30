#!/bin/bash

if [[ $1 == "sub" ]] ; then
    cd $(cut -d: -f2 .git)/hooks
    pwd
    [[ -f pre-commit ]] && rm pre-commit
    ln -s ~/scripts/pre-commit.py pre-commit
else
    while read repo ; do
        cd $repo
        [[ -f .gitmodules ]] && git submodule foreach ~/scripts/pre-commit-deploy.sh sub
        cd .git/hooks
        pwd
        [[ -f pre-commit ]] && rm pre-commit
        ln -s ~/scripts/pre-commit.py pre-commit
    done < ~/.gitrepos
fi
