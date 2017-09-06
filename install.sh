#!/bin/bash
# curl https://raw.githubusercontent.com/nim65s/scripts/master/install.sh | bash

# Fish sur Jessie:
# echo 'deb http://download.opensuse.org/repositories/shells:/fish:/release:/2/Debian_8.0/ /' >> /etc/apt/sources.list.d/fish.list

cd

mkdir -p .config .virtualenvs .ssh .virtualenvs
touch .gitrepos .ssh/authorized_keys

which pacman 2> /dev/null && sudo pacman -Syu --noconfirm git gvim fish openssh tinc vimpager python-pip python2-pip rofi pass
which apt 2> /dev/null && sudo apt install gnupg2 terminator git fish vim-gnome tinc pcscd libpcsclite1 pcsc-tools scdaemon
which yum 2> /dev/null && sudo yum install git fish vim tinc

echo enable-ssh-support > .gnupg/gpg-agent.conf
echo use-agent > .gnupg/gpg.conf
echo default-key 4653CF28 >> .gnupg/gpg.conf
echo personal-digest-preferences SHA256 >> .gnupg/gpg.conf
echo cert-digest-algo SHA256 >> .gnupg/gpg.conf
echo default-preference-list SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed > .gnupg/gpg.conf

killall gpg-agent
gpg-agent --daemon --enable-ssh-support --write-env-file ~/.gpg-agent-info
source ~/.gpg-agent-info

gpg2 --card-status || exit 1

grep -q cardno:000605255506 .ssh/authorized_keys || ssh-add -L >> .ssh/authorized_keys

for repo in dotfiles scripts VPNim
do
    test -d $repo || git clone git@github.com:nim65s/$repo.git --recursive
    pushd $repo
    git submodule update --recursive --remote --rebase --init
    git submodule foreach -q --recursive 'git checkout $(git config -f $toplevel/.gitmodules submodule.$name.branch || echo master)'
    grep -q $repo ~/.gitrepos || pwd >> ~/.gitrepos
    popd
done

for file in .bash_profile .bash_logout .tmux.conf .nanorc .vimpagerrc .vimrc .Xdefaults .gitconfig .bashrc .hgrc .zshrc .xmonad .vim .xinitrc .compton.conf .editorconfig .ipython .imapfilter .notmuch-config .msmtprc
do
    [[ -f $file ]] && rm $file
    ln -s $HOME/dotfiles/$file
done

for files in awesome dfc fish ipython pep8 ranger terminator zathura flake8 terminology fontconfig khal khard vdirsyncer todoman offlineimap mutt i3 i3status rofi
do
    [[ -d $files ]] && rm -rf .config/$files
    [[ -f $files ]] && rm $files
    ln -s $HOME/dotfiles/.config/$files $HOME/.config/
done

rm -f $HOME/.virtualenvs/global_requirements.txt
ln -s $HOME/dotfiles/global_requirements.txt $HOME/.virtualenvs/global_requirements.txt

pip2 install -U --user -r $HOME/dotfiles/global_requirements.txt virtualfish
pip3 install -U --user -r $HOME/dotfiles/global_requirements.txt virtualfish khal khard vdirsyncer todoman

echo "chsh -s $(grep fish /etc/shells)"
