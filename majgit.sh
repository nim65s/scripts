#!/bin/bash

cd ~/dotfiles
git pull origin master
git commit -a
git push origin master

cd ~/scripts
git pull origin master
git commit -a
git push origin master
