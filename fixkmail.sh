#!/bin/bash
cd /home/nim/.kde4/share/apps/kmail/mail/
for DOS in *
  do
    mkdir $DOS/cur $DOS/tmp $DOS/new
  done
exit 0
