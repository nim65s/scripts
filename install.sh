#!/bin/bash
# curl https://raw.githubusercontent.com/nim65s/scripts/master/install.sh | bash

# Fish sur Jessie:
# echo 'deb http://download.opensuse.org/repositories/shells:/fish:/release:/2/Debian_8.0/ /' >> /etc/apt/sources.list.d/fish.list

# TODO: dectect ssh & ssh forward agent

cd

mkdir -p .config .virtualenvs .ssh .virtualenvs
touch .gitrepos .ssh/authorized_keys

which pacman 2> /dev/null && sudo pacman -Syu --noconfirm git gvim fish openssh tinc
which apt-get 2> /dev/null && sudo apt-get install git fish vim-gnome tinc
which yum 2> /dev/null && sudo yum install git fish vim tinc

RM_ID=false

if [[ ! -d .ssh || (! -f .ssh/id_rsa  && ! -f .ssh/id_ed25519) ]]
then
    scp saurelg@ssh.inpt.fr:.ssh/id_rsa .ssh
    ssh-agent -s > .ssh/tmpagent
    . .ssh/tmpagent
    ssh-add
    RM_ID=true
fi

NAUSICAA_KEY='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDO1DwbWEyl9W9+VxqaIUH4XPVoKMpoxcyh2X9/1NcpTtMmkEwxAfQDONp0R8n4HGc7YpUUFQ0PgjIqhXaOz5zvWwr2wIf+1tPdV3lpxxNawZ8iAwwApaPqLdR0o0NAM8hKTbxB3ObVuzN5T5VJO/r4j1G4kH0wEiOrPnph5LPvkwGlMyIV8B7948v/CAe/YsTQA7jq6oijOAU/MTpjWjXANcDj688IgrDobx9L0T1oAhVrs11SqofrWuWTbgofLIR4mQhbm7t2DXha4kzD82lB9ia6TAXG9mysGsBYkIl2RZ9BA8Ax5ftou1zbtpYyO1SN5hytBi07BsYep/tHCSKn nim@Nausicaa'

grep -q $NAUSICAA_KEY .ssh/authorized_keys || echo $NAUSICAA_KEY >> .ssh/authorized_keys

for repo in dotfiles scripts VPNim
do
    rm -rf $repo
    git clone git@github.com:nim65s/$repo.git --recursive
    pushd $repo
    git submodule init
    git submodule update --recursive --remote --rebase
    git submodule foreach -q --recursive 'git checkout $(git config -f $toplevel/.gitmodules submodule.$name.branch || echo master)'
    grep -q $repo ~/.gitrepos || pwd >> ~/.gitrepos
    popd
done

$RM_ID && rm .ssh/{id_rsa,tmpagent}

for file in .bash_profile .bash_logout .tmux.conf .nanorc .vimpagerrc .vimrc .Xdefaults .gitconfig .bashrc .hgrc .zshrc .xmonad .vim .i3 .xinitrc .compton.conf .editorconfig
do
    rm -rf $file
    ln -s $HOME/dotfiles/$file
done

for files in awesome dfc fish ipython pep8 ranger terminator zathura flake8 terminology fontconfig
do
    rm -rf .config/$files
    ln -s $HOME/dotfiles/.config/$files $HOME/.config/
done

rm -f $HOME/.virtualenvs/global_requirements.txt
ln -s $HOME/dotfiles/global_requirements.txt $HOME/.virtualenvs/global_requirements.txt

echo "chsh -s $(grep fish /etc/shells)"
