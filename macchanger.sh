#!/bin/bash

if=${1:-wlp2s0}

sudo systemctl stop connman
sudo ip l set dev $if down
sudo macchanger -a $if
sudo ip l set dev $if up
sudo systemctl restart netctl-auto@$if
