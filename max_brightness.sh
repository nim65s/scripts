#!/bin/bash

cd /sys/class/backlight/intel_backlight/
echo ${1:-$(cat max_brightness)} > brightness
