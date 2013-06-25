#!/bin/bash

PACKAGES="git vim zsh"
which pacman > /dev/null 2&>1 && sudo pacman -Syu $PACKAGES
which apt-get > /dev/null 2&>1 && sudo apt-get install $PACKAGES

for repo in dotfiles script
do
    git clone git@github.com:nim65s/$repo.git
    cd $repo
    git submodule init
    git submodule update
    git submodule foreach git checkout master
done

for file in .bash_profile .bash_logout .tmux.conf .nanorc .xbindkeyrc .vimpagerrc .vimrc .Xdefaults .gitconfig .bashrc .hgrc .zshrc .xmonad
do
    ln -s dotfiles/$file
done

for files in dotfiles/.config/*
do
    ln -s $files .config
done
