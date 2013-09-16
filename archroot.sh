#!/bin/bash

myroot=$1

mkdir $myroot
mount --bind $myroot $myroot
pacstrap -i $myroot base base-devel
mount -t proc proc $myroot/proc/
mount -t sysfs sys $myroot/sys/
mount -o bind /dev $myroot/dev/
mount -t devpts pts $myroot/dev/pts/
cp -i /etc/resolv.conf $myroot/etc/
chroot $myroot /bin/bash

