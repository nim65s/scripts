#!/bin/bash
# curl https://raw.githubusercontent.com/nim65s/scripts/master/install.sh | bash

# Fish sur Jessie:
# echo 'deb http://download.opensuse.org/repositories/shells:/fish:/release:/2/Debian_8.0/ /' >> /etc/apt/sources.list.d/fish.list

cd

which pacman 2> /dev/null && sudo pacman -Syu --noconfirm git gvim fish openssh
which apt-get 2> /dev/null && yes|sudo apt-get install git fish vim-gnome
which yum 2> /dev/null && yes|sudo yum install git fish vim

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

$RM_ID_RSA && rm .ssh/{id_rsa,tmpagent}

for file in .bash_profile .bash_logout .tmux.conf .nanorc .xbindkeyrc .vimpagerrc .vimrc .Xdefaults .gitconfig .bashrc .hgrc .zshrc .xmonad .vim .i3 .xinitrc .isort.cfg
do
    rm -rf $file
    ln -s $HOME/dotfiles/$file
done

for files in awesome dfc fish ipython pep8 ranger terminator zathura
do
    rm -rf .config/$files
    ln -s $HOME/dotfiles/.config/$files $HOME/.config/
done

echo "chsh -s $(grep fish /etc/shells)"
