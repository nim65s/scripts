#!/bin/bash

in=${1:-wlp2s0}
internet=${2:-enp0s20u1}

sudo iptables -t nat -A POSTROUTING -o $internet -j MASQUERADE
sudo iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i $in -o $internet -j ACCEPT
sudo sysctl net.ipv4.ip_forward=1
