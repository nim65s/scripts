#!/bin/bash
cd $HOME/.config/awesome
mv rc.lua kako.rc.lua
cp kaok.rc.lua rc.lua
rm 12*

read -p 'restart kdm ? (y|o/n)' ans
case $ans in
    o* | O* | y* | Y*)
	sudo /etc/rc.d/kdm restart
	;;
    n* | *)
	;;
esac

exit
