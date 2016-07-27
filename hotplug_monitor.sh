#!/bin/bash

main=${1:-eDP1}
direction=${2:-above}

for output in $(xrandr | grep -v '^ \|^Screen' | cut -d' ' -f1)
do
    if [[ $output == $main ]]
    then
        xrandr --output ${output} --auto --primary
    elif xrandr | grep -q "${output} connected"
    then
        xrandr --output ${output} --auto --${direction} ${main}
    else
        xrandr --output ${output} --off
    fi
done
