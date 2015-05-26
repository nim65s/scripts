#!/bin/bash

in=${1:-wlp2s0}
out=${2:-enp0s20u1}

sudo iptables -t nat -A POSTROUTING -o $out -j MASQUERADE
sudo iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i $in -o $out -j ACCEPT
sudo sysctl net.ipv4.ip_forward=1
