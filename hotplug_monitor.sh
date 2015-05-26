#!/bin/bash

if $(xrandr | grep -q "VGA1 connected")
then
    xrandr --output VGA1 --auto --right-of LVDS1
else
    xrandr --output VGA1 --off
fi
