#!/bin/bash

PROG=false

for p in $(echo $PATH|sed 's/:/ /g')
do [[ -e $p/$1 ]] && PROG=true
done

if $PROG
then
    nombre=$RANDOM
    let "nombre %= $#"
    for((i=0;i<$nombre;i++))
    do shift
    done
    echo $1
else
    programme="$1"
    shift
    $programme $($0 $@)
fi

exit 0
		
