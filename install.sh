#!/bin/bash
# curl https://raw.githubusercontent.com/nim65s/scripts/master/install.sh | bash

cd

which pacman 2> /dev/null && sudo pacman -Syu --noconfirm git gvim zsh openssh
which apt-get 2> /dev/null && yes|sudo apt-get install git zsh vim-gnome
which yum 2> /dev/null && yes|sudo yum install git zsh vim

RM_ID_RSA=false

if [[ ! -d ~/.ssh || ! -f ~/.ssh/id_rsa ]]
then
    mkdir -p ~/.ssh
    scp saurelg@ssh.inpt.fr:.ssh/id_rsa .ssh

    ssh-agent -s > ~/.ssh/tmpagent
    . ~/.ssh/tmpagent
    ssh-add
    RM_ID_RSA=true
fi

for repo in dotfiles scripts
do
    rm -rf $HOME/$repo
    git clone git@github.com:nim65s/$repo.git
    cd $repo
    git submodule init
    git submodule update
    git submodule foreach git checkout master
    cd
    grep -q $repo .gitrepos 2> /dev/null || echo $HOME/$repo >> .gitrepos
done

$RM_ID_RSA && rm .ssh/id_rsa

for file in .bash_profile .bash_logout .tmux.conf .nanorc .xbindkeyrc .vimpagerrc .vimrc .Xdefaults .gitconfig .bashrc .hgrc .zshrc .xmonad .vim .i3 .xinitrc .isort.cfg
do
    rm -rf $file
    ln -s $HOME/dotfiles/$file
done

for files in awesome dfc fish ipython pep8 ranger terminator zathura
do
    rm -rf .config/$files
    ln -s $HOME/dotfiles/.config/$files .config
done

echo "Don't forget to «chsh -s $(which zsh) $USER» and to «rm ~/.ssh/tmpagent»"
