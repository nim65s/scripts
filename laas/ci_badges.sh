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


[[ -d $ORG/$PRJ ]]
cd $ORG/$PRJ

git checkout devel
git pull --rebase main devel
git submodule update

hostname -f | grep -q laas.fr || export ALL_PROXY="socks5h://localhost:1445"
echo "include: http://rainboard.laas.fr/project/$PRJ/.gitlab-ci.yml" > .gitlab-ci.yml

cat >> README.md << EOF

[![Pipeline status](https://gitlab.laas.fr/$ORG/$PRJ/badges/master/pipeline.svg)](https://gitlab.laas.fr/$ORG/$PRJ/commits/master)
[![Coverage report](https://gitlab.laas.fr/$ORG/$PRJ/badges/master/coverage.svg?job=doc-coverage)](http://projects.laas.fr/gepetto/doc/$ORG/$PRJ/master/coverage/)

EOF

$EDITOR README.md
git add .
git commit
git submodule foreach git checkout master
git submodule foreach git pull
git commit -am 'sync submodules'
git push origin devel

echo ./mirror.sh $ORG $PRJ
