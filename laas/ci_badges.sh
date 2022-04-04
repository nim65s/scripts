#!/bin/bash -eux

ORG=${1%/*}
PRJ=${1#*/}

GL=gitlab.laas.fr
GH=github.com

ML=gsaurel
MH=nim65s

browse https://rainboard.laas.fr/project/$PRJ/robotpkg

for url in $GL/$ML $GH/$MH $GL/$ORG $GH/$ORG
do
    curl -sI https://$url/$PRJ | head -n1 | grep -q 200 || echo "NOPE https://$url/$PRJ" >> /dev/stderr &
done

wait


[[ -d $ORG/$PRJ ]]
cd $ORG/$PRJ

git checkout devel
git pull --rebase main devel
git pull --rebase github devel
git submodule update

#hostname -f | grep -q laas.fr || export ALL_PROXY="socks5h://localhost:1445"
echo "include: http://rainboard.laas.fr/project/$PRJ/.gitlab-ci.yml" > .gitlab-ci.yml

TEMPLATE=$HOME/local/template
if fd -q -E cmake -e py
then
    [[ -f setup.cfg ]] && $EDITOR setup.cfg || cp $TEMPLATE/setup.cfg .
    [[ -f pyproject.toml ]] && $EDITOR pyproject.toml || cp $TEMPLATE/pyproject.toml .
fi
[[ -f .pre-commit-config.yaml ]] && $EDITOR .pre-commit-config.yaml || cp $TEMPLATE/.pre-commit-config.yaml .pre-commit-config.yaml
[[ -f .clang-format ]] && rm .clang-format

cat >> README.md << EOF

[![Pipeline status](https://gitlab.laas.fr/$ORG/$PRJ/badges/master/pipeline.svg)](https://gitlab.laas.fr/$ORG/$PRJ/commits/master)
[![Coverage report](https://gitlab.laas.fr/$ORG/$PRJ/badges/master/coverage.svg?job=doc-coverage)](http://projects.laas.fr/gepetto/doc/$ORG/$PRJ/master/coverage/)
[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)
[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/$ORG/$PRJ/master.svg)](https://results.pre-commit.ci/latest/github/$ORG/$PRJ)

EOF

$EDITOR README.md
git add .
git commit -m 'update tools & badges' || true
git submodule foreach git checkout master
git submodule foreach git pull
git commit -am 'sync submodules' || true

pre-commit install
pre-commit run -a || true
fd -q -E cmake -e py && black . || true
while ! flake8 .
do sleep 1
done

git commit -am 'format' || true

git log --oneline --grep 'lint\|yapf\|format' "--format=format:# %s (%an, %as)%n%H%n" >> .git-blame-ignore-revs
$EDITOR .git-blame-ignore-revs

git add .git-blame-ignore-revs
git commit -m 'git blame ignore revs' || true

git push origin devel
browse https://$GL/$ML/$PRJ/pipelines

#echo ./mirror.sh $ORG $PRJ
