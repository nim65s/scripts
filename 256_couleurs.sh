#!/bin/bash
for((i=0;i<8;i++))
do 
    echo -en "\033[38;5;${i}m $i "
done 
echo
for((i=8;i<10;i++))
do 
    echo -en "\033[38;5;${i}m $i "
done
for((i=10;i<16;i++))
do 
    echo -en "\033[38;5;${i}m$i "
done
echo
echo
for((i=0;i<6;i++))
do
    for((j=0;j<6;j++))
    do
        for((k=0;k<6;k++))
        do
            echo -en "\033[38;5;$((16 + $k + 6*$j + 36*$i))m"
            [[ $((16 + $k + 6*$j + 36*$i)) -lt 100 ]] && echo -en " "
            echo -en "$((16 + $k + 6*$j + 36*$i)) "
        done
        echo
    done
    echo
done
echo

for((i=232;i<256;i++))
do 
    echo -en "\033[38;5;${i}m$i "
done
echo


