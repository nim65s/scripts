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
        CMD="--image $HOME/images/xcowsay/pikachu.png $* PIKACHU !"
        ;;
    sacha)
        shift
        CMD="--image $HOME/images/xcowsay/sacha.png $* GOTTA CATCH THEM ALL !"
        ;;
    tortue)
        shift
        declare -a CMD
        CMD0="--image $HOME/images/xcowsay/tortue_1.gif $* COWABUNGA !"  
        CMD1="--image $HOME/images/xcowsay/tortue_2.gif $* COWABUNGA !"  
        CMD2="--image $HOME/images/xcowsay/tortue_3.gif $* COWABUNGA !"  
        CMD3="--image $HOME/images/xcowsay/tortue_4.gif $* COWABUNGA !"
        CMD=($CMD0 $CMD1 $CMD2 $CMD3 $CMD4)
        ;;
    *)
        CMD=$*
        ;;
esac


if [[ "`hostname`" == "totoro" ]]
then
    for((j=0;j<=$N;j++))
    do
        DISPLAY=:0.1 xcowsay ${CMD{$j}} &
        sleep 1
    done
else
    for((j=0;j<=$N;j++))
    do
        for client in amy bender fry leela hermes farnsworth scruffy
        do
            for((i=0;i<6;i++))
            do
                ssh $client DISPLAY=:$i xcowsay $CMD &
                sleep 1
            done
        done
    done
fi

wait
