#!/bin/bash

if $(xrandr | grep -q "VGA1 connected")
then
    xrandr --output VGA1 --auto --right-of LVDS1
elif $(xrandr | grep -q "HDMI1 connected")
then
    xrandr --output HDMI1 --auto --right-of LVDS1
else
    xrandr --output VGA1 --off
    xrandr --output HDMI1 --off
fi
