#!/bin/bash

if [[ $(qdbus --system org.bluez /org/bluez/hci0/dev_00_0C_8A_67_96_90 org.bluez.Device1.Connected) = "false" ]]
then
    dbus-send --system --print-reply --dest=org.bluez /org/bluez/hci0 org.freedesktop.DBus.Properties.Set string:"org.bluez.Adapter1" string:"Powered" variant:boolean:true
fi

while [[ $(qdbus --system org.bluez /org/bluez/hci0/dev_00_0C_8A_67_96_90 org.bluez.Device1.Connected) = "false" && $(acpi -a) = 'Adapter 0: on-line' ]]
do
    dbus-send --system --print-reply --dest=org.bluez /org/bluez/hci0/dev_00_0C_8A_67_96_90 org.bluez.Device1.Connect 2> /dev/null
done

dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Pause > /dev/null
dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause > /dev/null
