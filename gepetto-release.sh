#!/bin/bash

[[ -x cmake/git-archive-all.sh ]] || exit 1

TAG=$1
SOFT=${2:-$(basename $(pwd))}
KEY=${3:-4653CF28}

echo Releasing $SOFT $TAG

rm -vf *.tar* /tmp/*.tar*
git tag -u $KEY -s "v$TAG" -m "Release v$TAG" || exit
./cmake/git-archive-all.sh --prefix "${SOFT}-${TAG}/" -v "${SOFT}-${TAG}.tar" || exit
gzip "${SOFT}-${TAG}.tar" || exit
gpg --armor -u $KEY --detach-sign "${SOFT}-${TAG}.tar.gz" || exit
git push --tags || exit
