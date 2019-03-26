#!/bin/bash

ORG=${1}
PRJ=${2}

GL=gepgitlab.laas.fr
GH=github.com

ML=gsaurel
MH=nim65s
set -e

for url in $GL/$ML $GH/$MH $GL/$ORG $GH/$ORG
do
    curl -sI "https://$url/$PRJ" | head -n1 | grep -q 200 || echo "NOPE https://$url/$PRJ" >> /dev/stderr &
done

wait

[[ -d $ORG/$PRJ ]]

cd "$ORG/$PRJ"
git fetch --all --prune

git checkout devel
git submodule update
git pull --rebase main devel
git branch --set-upstream-to=origin/devel devel

git checkout master
git submodule update
git pull --rebase main master
git branch --set-upstream-to=origin/master master

tput bold
echo "master / devel: -$(git rev-list master..devel | wc -l)|+$(git rev-list devel..master | wc -l)"
tput sgr0

git checkout devel
git submodule update
git push origin devel
git checkout master
git submodule update
git push origin master
git push --tags origin master

tput bold
echo "devel / main/devel: -$(git rev-list devel..main/devel | wc -l)|+$(git rev-list main/devel..devel | wc -l)"
echo "master / main/master: -$(git rev-list master..main/master | wc -l)|+$(git rev-list main/master..master | wc -l)"
tput sgr0

if [[ $(git diff devel..main/devel | wc -l) == 0 ]]
then
    git checkout devel
    git submodule update
    git push maingl devel
fi

if [[ $(git diff master..main/master | wc -l) == 0 ]]
then
    git checkout master
    git submodule update
    git push maingl master
    git push --tags maingl master
fi
