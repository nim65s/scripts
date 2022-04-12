#!/bin/bash

ORG=${1}
PRJ=${2}

GL=gitlab.laas.fr
GH=github.com

ML=gsaurel
MH=nim65s
set -e

for url in $GL/$ML $GH/$MH $GL/$ORG $GH/$ORG
do
    curl -sI https://$url/$PRJ | head -n1 | grep -q 200 || echo "NOPE https://$url/$PRJ" >> /dev/stderr &
done

wait

mkdir -p $ORG
cd $ORG

[[ ! -d $PRJ ]]

git clone --recursive git@$GL:$ML/$PRJ.git
cd $PRJ

git checkout devel
git checkout master

git remote add github git@$GH:$MH/$PRJ.git
git remote add maingl git@$GL:$ORG/$PRJ.git
git remote add main   git@$GH:$ORG/$PRJ.git
git fetch --all --prune
