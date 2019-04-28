#!/bin/bash
# curl https://raw.githubusercontent.com/nim65s/scripts/master/nim_docker.sh | bash

[[ -f /etc/debian_version ]] && apt update -qqy && apt install -qqy vim htop ncdu git tig fish gnupg2 dfc
[[ -f /etc/arch-release ]]   && pacman -Syu --noconfirm             vim htop ncdu git tig fish gnupg  dfc
[[ -f /etc/alpine-release ]] && apk add                             vim htop ncdu git tig fish gnupg

cd
git clone --depth 1 https://github.com/nim65s/dotfiles.git
cd dotfiles
git submodule update --init Zenburn vim-plug submodules/docker-fish-completion

cd
for file in .bash_profile .bash_logout .tmux.conf .nanorc .vimpagerrc .vimrc .Xdefaults .gitconfig .bashrc .hgrc .zshrc .xmonad .vim .xinitrc .compton.conf .editorconfig .ipython .imapfilter .notmuch-config .msmtprc .pypirc
do
    [[ -L $file || -f $file ]] && rm $file
    ln -s $HOME/dotfiles/$file
done

mkdir -p .config
cd .config
for files in awesome dfc fish pep8 ranger terminator zathura flake8 terminology fontconfig khal khard vdirsyncer todoman offlineimap mutt i3 i3status rofi dunst pylintrc
do
    [[ -L $files ]] && rm $files
    ln -s $HOME/dotfiles/.config/$files
done
