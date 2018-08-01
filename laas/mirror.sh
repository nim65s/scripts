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
    curl -sI https://$url/$PRJ | head -n1 | grep -q 200 || echo "NOPE https://$url/$PRJ" >> /dev/stderr &
done

wait

[[ -d $ORG/$PRJ ]]

cd $ORG/$PRJ
git fetch origin &
git fetch github &
git fetch maingl &
git fetch main   &

wait

git checkout devel
git pull --rebase main devel
git checkout master
git pull --rebase main master

tput bold
echo "master / devel: -$(git rev-list master..devel | wc -l)|+$(git rev-list devel..master | wc -l)"
tput sgr0

git checkout devel
git push origin devel
git checkout master
git push origin master

[[ $(git diff devel..main/devel | wc -l) == 0 ]]
[[ $(git diff master..main/master | wc -l) == 0 ]]

git checkout devel
git push maingl devel
git checkout master
git push maingl master


