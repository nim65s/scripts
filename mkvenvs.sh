#!/bin/bash

[[ -z $WORKON_HOME ]] && WORKON_HOME=~/.virtualenvs
[[ -d $WORKON_HOME ]] || mkdir -p $WORKON_HOME

. $(which virtualenvwrapper.sh)

while read repo ; do
    if [[ $repo == -* ]] ; then
        echo $repo
    else
        echo -e "\033[1;32m $repo \033[0m"
        cd $repo || exit 1
        if [[ -f requirements.txt ]] ; then
            if [[ -f .venv ]] ; then
                if [[ -d $WORKON_HOME/$(cat .venv) ]] ; then
                    workon $(cat .venv)
                    pip install -U -r requirements.txt -r ~/dotfiles/global_requirements.txt | grep -v 'Requirement already up-to-date:\|Double requirement given:'
                else
                    echo .venv here but no $WORKON_HOME/$(cat .venv)
                fi
            else
                echo missing .venv
            fi
        fi
    fi
done < ~/.gitrepos
