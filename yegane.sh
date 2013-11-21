#!/bin/bash

if [[ -x ~/.cabal/bin/yeganesh ]]
then
    CMD=$(~/.cabal/bin/yeganesh -x)
    $CMD
else
    dmenu_run
fi
