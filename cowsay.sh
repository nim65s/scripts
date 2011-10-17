#!/bin/bash

if [[ "$1" == "n" ]]
then
    shift
    N=$1
    shift
else
    N=1
fi

case $1 in 
    pikachu)
        shift
        CMD="--image /home/saurelg/images/xcowsay/pikachu.png $* PIKACHU !"
        ;;
    sacha)
        shift
        CMD="--image /home/saurelg/images/xcowsay/sacha.png $* GOTTA CATCH THEM ALL !"
        ;;
    *)
        CMD=$*
        ;;
esac


for((j=0;j<=$N;j++))
do
    for client in amy bender fry leela hermes farnsworth scruffy
    do
        for((i=0;i<6;i++))
        do
            ssh $client DISPLAY=:$i xcowsay $CMD &
        done
    done
done

wait
