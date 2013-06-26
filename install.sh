#!/bin/bash
# curl https://raw.github.com/nim65s/scripts/master/install.sh | bash

cd

which pacman 2> /dev/null && sudo pacman -Syu --noconfirm git gvim zsh openssh
which apt-get 2> /dev/null && sudo apt-get install git zsh vim-gnome

mkdir ~/.ssh
scp saurelg@ssh.inpt.fr:.ssh/id_rsa .ssh

ssh-agent -s > ~/.ssh/tmpagent
. ~/.ssh/tmpagent
ssh-add

for repo in dotfiles scripts
do
    git clone git@github.com:nim65s/$repo.git
    cd $repo
    git submodule init
    git submodule update
    git submodule foreach git checkout master
    cd
done

rm .ssh/id_rsa

for file in .bash_profile .bash_logout .tmux.conf .nanorc .xbindkeyrc .vimpagerrc .vimrc .Xdefaults .gitconfig .bashrc .hgrc .zshrc .xmonad .vim
do
    rm $file
    ln -s dotfiles/$file
done

for files in awesome dfc fish ipython pep8 ranger terminator zathura
do
    rm -rf .config/$files
    ln -s dotfiles/.config/$files .config
done
