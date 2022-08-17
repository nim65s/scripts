#!/bin/bash -eux

URL=${1%/}
ORG=${URL%/*}
PRJ=${URL#*/}

GL=gitlab.laas.fr
GH=github.com

ML=gsaurel
MH=nim65s

xdg-open "https://rainboard.laas.fr/project/$PRJ/robotpkg"

for url in $GL/$ML $GH/$MH $GL/$ORG $GH/$ORG
do
    curl -sI "https://$url/$PRJ" | head -n1 | grep -q 200 || echo "NOPE https://$url/$PRJ" >> /dev/stderr &
done

wait


[[ -d $ORG/$PRJ ]]
cd "$ORG/$PRJ"

git checkout devel
git pull --rebase origin devel
git pull --rebase github devel
git pull --rebase main devel
git submodule update

#hostname -f | grep -q laas.fr || export ALL_PROXY="socks5h://localhost:1445"
echo "include: http://rainboard.laas.fr/project/${PRJ/_/-}/.gitlab-ci.yml" > .gitlab-ci.yml

TEMPLATE=$HOME/local/template
if fd -q -E cmake -e py
then
    if [[ -f setup.cfg ]]
    then $EDITOR setup.cfg
    else cp "$TEMPLATE/setup.cfg" .
    fi
    if [[ -f pyproject.toml ]]
    then $EDITOR pyproject.toml
    else cp "$TEMPLATE/pyproject.toml" .
    fi
fi
if [[ -f .pre-commit-config.yaml ]]
then $EDITOR .pre-commit-config.yaml
else cp "$TEMPLATE/.pre-commit-config.yaml" .pre-commit-config.yaml
fi
[[ -f .clang-format ]] && rm .clang-format

cat >> README.md << EOF

[![Pipeline status](https://gitlab.laas.fr/$ORG/$PRJ/badges/master/pipeline.svg)](https://gitlab.laas.fr/$ORG/$PRJ/commits/master)
[![Coverage report](https://gitlab.laas.fr/$ORG/$PRJ/badges/master/coverage.svg?job=doc-coverage)](https://gepettoweb.laas.fr/doc/$ORG/$PRJ/master/coverage/)
[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)
[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/$ORG/$PRJ/master.svg)](https://results.pre-commit.ci/latest/github/$ORG/$PRJ)

EOF

$EDITOR README.md
git add .
test -n "$(git status --porcelain)" && git commit -m 'update tools & badges'
if grep -q 'git://github.com' .gitmodules
then
    sed -i 's=git://=https://=' .gitmodules
    git add .gitmodules
    git commit -m 'fix submodule url'
fi
git submodule foreach git checkout master
git submodule foreach git pull
test -n "$(git status --porcelain)" && git commit -am 'sync submodules'

pre-commit install
pre-commit run -a || true
if fd -q -E cmake -e py
then
    black . || true
fi
while ! flake8 .
do sleep 1
done

test -n "$(git status --porcelain)" && git commit -am 'format'

git log --oneline --grep 'lint\|yapf\|format\|pre-commit' "--format=format:# %s (%an, %as)%n%H%n" >> .git-blame-ignore-revs
$EDITOR .git-blame-ignore-revs

git add -f .git-blame-ignore-revs
test -n "$(git status --porcelain)" && git commit -m 'git blame ignore revs'

git push origin devel
xdg-open "https://$GL/$ML/$PRJ/pipelines"

#echo ./mirror.sh $ORG $PRJ
