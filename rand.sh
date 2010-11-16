#!/bin/bash

if [[ -e "$1" ]]
then
		nombre=$RANDOM
		let "nombre %= $#"
		for((i=0;i<$nombre;i++))
		do
				shift
		done
		echo $1
else
		programme="$1"
		shift
		$programme $($0 $@)
fi

exit 0
		
