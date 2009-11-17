#!/bin/bash
IFS=$'\n'
if [ -e "$1" ]
  then
    nombre=$RANDOM
    let "nombre %= $#"
    for((i=0;i<$nombre;i++))
      do
        shift
      done
    echo $1
  else
    programme=$1
    shift
    nombre=$RANDOM
    let "nombre %= $#"
    for((i=0;i<$nombre;i++))
      do
        shift
      done
    $programme $1
  fi
exit

