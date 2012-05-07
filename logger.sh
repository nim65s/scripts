#!/bin/bash
while read l
do echo "$(date +"[%F %T]") $l"
done < /dev/stdin
