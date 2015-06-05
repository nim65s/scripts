#!/bin/bash

echo ${1:-$(cat /sys/class/backlight/intel_backlight/max_brightness)} > /sys/class/backlight/intel_backlight/brightness
