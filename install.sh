#!/bin/bash
# curl https://raw.githubusercontent.com/nim65s/scripts/master/install.sh | bash

# Fish sur Jessie:
# echo 'deb http://download.opensuse.org/repositories/shells:/fish:/release:/2/Debian_8.0/ /' >> /etc/apt/sources.list.d/fish.list

# TODO: dectect ssh & ssh forward agent

cd

mkdir -p .config

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

echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDO1DwbWEyl9W9+VxqaIUH4XPVoKMpoxcyh2X9/1NcpTtMmkEwxAfQDONp0R8n4HGc7YpUUFQ0PgjIqhXaOz5zvWwr2wIf+1tPdV3lpxxNawZ8iAwwApaPqLdR0o0NAM8hKTbxB3ObVuzN5T5VJO/r4j1G4kH0wEiOrPnph5LPvkwGlMyIV8B7948v/CAe/YsTQA7jq6oijOAU/MTpjWjXANcDj688IgrDobx9L0T1oAhVrs11SqofrWuWTbgofLIR4mQhbm7t2DXha4kzD82lB9ia6TAXG9mysGsBYkIl2RZ9BA8Ax5ftou1zbtpYyO1SN5hytBi07BsYep/tHCSKn nim@Nausicaa' >> .ssh/authorized_keys

for repo in dotfiles scripts
do
    rm -rf $HOME/$repo
    git clone git@github.com:nim65s/$repo.git
    cd $repo
    git submodule init
    git submodule update --recursive --remote --rebase
    git submodule foreach -q --recursive 'git checkout $(git config -f $toplevel/.gitmodules submodule.$name.branch || echo master)'
    cd
    grep -q $repo .gitrepos 2> /dev/null || echo $HOME/$repo >> .gitrepos
done

$RM_ID_RSA && rm .ssh/{id_rsa,tmpagent}

for file in .bash_profile .bash_logout .tmux.conf .nanorc .xbindkeyrc .vimpagerrc .vimrc .Xdefaults .gitconfig .bashrc .hgrc .zshrc .xmonad .vim .i3 .xinitrc .isort.cfg
do
    rm -rf $file
    ln -s $HOME/dotfiles/$file
done

for files in awesome dfc fish ipython pep8 ranger terminator zathura flake8
do
    rm -rf .config/$files
    ln -s $HOME/dotfiles/.config/$files $HOME/.config/
done

echo "chsh -s $(grep fish /etc/shells)"
