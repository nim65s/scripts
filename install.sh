#!/bin/bash
# vim: tw=0
# curl https://raw.githubusercontent.com/nim65s/scripts/master/install.sh | bash

set -e
set -x

cd

mkdir -p .config .ssh .gnupg
touch .gitrepos .ssh/authorized_keys

which pacman 2> /dev/null && sudo pacman -Syu --noconfirm git gvim fish openssh tinc vimpager python-pip rofi pass pcsc-tools ccid libusb-compat dunst msmtp-mta
which apt 2> /dev/null && sudo apt install -qqy gnupg2 terminator git fish vim-gnome tinc pcscd libpcsclite1 pcsc-tools scdaemon python-pip python3-pip msmtp-mta
which yum 2> /dev/null && sudo yum install git fish vim tinc python2-pip python3-pip gcc

if [[ -z "$SSH_CLIENT" ]]
then
    echo enable-ssh-support > .gnupg/gpg-agent.conf
    echo use-agent > .gnupg/gpg.conf
    echo default-key 7D2ACDAF4653CF28 >> .gnupg/gpg.conf
    echo personal-digest-preferences SHA256 >> .gnupg/gpg.conf
    echo cert-digest-algo SHA256 >> .gnupg/gpg.conf
    echo default-preference-list SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed >> .gnupg/gpg.conf

    gpg-connect-agent reloadagent /bye

    # Check Key
    gpg2 --card-status
    curl $(gpg2 --card-status|grep key.asc|cut -d: -f2-) | gpg --import
    rm -f /tmp/secret{,.gpg}
    echo 'IT WORKS \o/' > /tmp/secret
    gpg --encrypt --trusted-key 7D2ACDAF4653CF28 -r 7D2ACDAF4653CF28 /tmp/secret
    gpg --decrypt /tmp/secret.gpg
fi

grep -q cardno:000605255506 .ssh/authorized_keys || ssh-add -L >> .ssh/authorized_keys

for repo in dotfiles scripts VPNim
do
    test -d $repo || git clone git@github.com:nim65s/$repo.git --recursive
    pushd $repo
    git pull --rebase
    git submodule update --recursive --remote --rebase --init
    git submodule foreach -q --recursive 'git checkout $(git config -f $toplevel/.gitmodules submodule.$name.branch || echo master)'
    grep -q $repo ~/.gitrepos || pwd >> ~/.gitrepos
    popd
done

for file in .bash_profile .bash_logout .tmux.conf .nanorc .vimpagerrc .vimrc .Xdefaults .gitconfig .bashrc .hgrc .zshrc .xmonad .vim .xinitrc .compton.conf .editorconfig .ipython .imapfilter .notmuch-config .msmtprc .pypirc
do
    [[ -L $file || -f $file ]] && rm $file
    ln -s $HOME/dotfiles/$file
done

cd ~/.config
for files in awesome dfc fish pep8 ranger terminator zathura flake8 terminology fontconfig khal khard vdirsyncer todoman offlineimap mutt i3 i3status rofi dunst pylintrc
do
    [[ -L $files ]] && rm $files
    ln -s $HOME/dotfiles/.config/$files
done
cd

pip2 install -U --user pip
pip3 install -U --user pip
pip3 install -U --user IPython pygments_zenburn flake8 isort pep8-naming khal khard vdirsyncer todoman youtube-dl thefuck pandocfilters wheel twine pipenv docker-compose
pip2 install -U --user IPython pygments_zenburn rename

grep $USER /etc/passwd | grep -q fish || echo "chsh -s $(grep fish /etc/shells)"
