#!/bin/bash

[[ -z $1 ]] && BRIGHT=$(cat /sys/class/backlight/intel_backlight/max_brightness) || BRIGHT=$1

echo $BRIGHT > /sys/class/backlight/intel_backlight/brightness
