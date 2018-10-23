#!/bin/bash

for org in gepetto stack-of-tasks humanoid-path-planner
do
    pushd $org
    for project in *
    do
        pushd $project
        git fetch --all
        popd
        echo
        sleep 2
    done
    popd
done
