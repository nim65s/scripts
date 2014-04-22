#!/bin/bash
# curl https://raw.github.com/nim65s/scripts/master/install.sh | bash

cd

which pacman 2> /dev/null && sudo pacman -Syu --noconfirm git gvim zsh openssh
which apt-get 2> /dev/null && yes|sudo apt-get install git zsh vim-gnome
which yum 2> /dev/null && yes|sudo yum install git zsh vim

mkdir -p ~/.ssh
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
    grep -q $repo .gitrepos 2> /dev/null || echo $HOME/$repo >> .gitrepos
done

rm .ssh/id_rsa

for file in .bash_profile .bash_logout .tmux.conf .nanorc .xbindkeyrc .vimpagerrc .vimrc .Xdefaults .gitconfig .bashrc .hgrc .zshrc .xmonad .vim .i3 .xinitrc
do
    rm -f $file
    ln -s dotfiles/$file
done

for files in awesome dfc fish ipython pep8 ranger terminator zathura
do
    rm -rf .config/$files
    ln -s dotfiles/.config/$files .config
done

echo "Don't forget to «chsh -s $(which zsh) $USER» and to «rm ~/.ssh/tmpagent»"
