#!/bin/bash

case $1 in 
    pikachu)
        CMD="--image /home/saurelg/images/xcowsay/pikachu.png PIKACHU !"
        ;;
    sacha)
        CMD="--image /home/saurelg/images/xcowsay/sacha.png GOTTA CATCH THEM ALL !"
        ;;
    *)
        CMD=$*
        ;;
esac


for client in amy bender fry leela hermes farnsworth scruffy
do
    for i in 1 2 3 4 5 
    do
        ssh $client DISPLAY=:$i xcowsay $CMD &
    done
done
