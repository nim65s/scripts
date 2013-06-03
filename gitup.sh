#!/bin/bash

while read repo
do (( cd $repo && git pull && [[ -f .gitmodules ]] && git submodule foreach git pull && git status|| true ) | grep -v 'Already up-to-date.\|nothing to commit, working directory clean\|# On branch master\|^Entering' ) &
done < ~/.gitrepos

wait
