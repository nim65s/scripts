#!/bin/bash
cd /home/nim/.config/awesome/
cp rc.lua `date +%s`.rc.lua
kate rc.lua 2> /dev/null
exit
