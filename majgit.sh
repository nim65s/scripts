#!/bin/bash

cd ~/dotfiles
echo -e "\t\t == pull dotfiles =="
git pull origin master
git commit -a
echo -e "\t\t == push dotfiles =="
git push origin master

cd ~/scripts
echo -e "\t\t == pull scripts =="
git pull origin master
git commit -a
echo -e "\t\t == push scripts =="
git push origin master

[[ `hostname` != 'totoro' ]] && ssh -A /home/nim/scripts/majgit.sh
