#!/bin/bash
# vim: tw=0
# curl https://raw.githubusercontent.com/nim65s/scripts/master/install.sh | bash

set -e
set -x

cd

mkdir -p .config .virtualenvs .ssh .virtualenvs .gnupg
touch .gitrepos .ssh/authorized_keys

which pacman 2> /dev/null && sudo pacman -Syu --noconfirm git gvim fish openssh tinc vimpager python-pip rofi pass pcsc-tools ccid libusb-compat dunst msmtp-mta
which apt 2> /dev/null && sudo apt install -qqy gnupg2 terminator git fish vim-gnome tinc pcscd libpcsclite1 pcsc-tools scdaemon python-pip python3-pip msmtp-mta
which yum 2> /dev/null && sudo yum install git fish vim tinc

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

for file in .bash_profile .bash_logout .tmux.conf .nanorc .vimpagerrc .vimrc .Xdefaults .gitconfig .bashrc .hgrc .zshrc .xmonad .vim .xinitrc .compton.conf .editorconfig .ipython .imapfilter .notmuch-config .msmtprc
do
    [[ -L $file || -f $file ]] && rm $file
    ln -s $HOME/dotfiles/$file
done

cd ~/.config
for files in awesome dfc fish pep8 ranger terminator zathura flake8 terminology fontconfig khal khard vdirsyncer todoman offlineimap mutt i3 i3status rofi dunst
do
    [[ -L $files ]] && rm $files
    ln -s $HOME/dotfiles/.config/$files
done
cd

export PYENV_ROOT=$HOME/dotfiles/pyenv
export PATH=$PYENV_ROOT/bin:$PATH
eval "$(pyenv init -)"
cd $PYENV_ROOT/plugins
rm -f pyenv-virtualenv
ln -s ../../pyenv-virtualenv
pyenv install -s pypy3.5-5.9.0
pyenv install -s pypy2.7-5.9.0
pyenv virtualenvs | grep -q tools && pyenv virtualenv-delete -f tools
pyenv virtualenvs | grep -q twols && pyenv virtualenv-delete -f twols
pyenv virtualenv pypy3.5-5.9.0 tools
pyenv virtualenv pypy2.7-5.9.0 twols
pyenv activate tools
pip install -U flake8 IPython isort pep8-naming pip-tools pygments_zenburn khal khard vdirsyncer todoman youtube-dl thefuck tqdm tabulate grequests pandocfilters
pyenv activate twols
pip install -U IPython rename
pyenv global tools twols system

grep $USER /etc/passwd | grep -q fish || echo "chsh -s $(grep fish /etc/shells)"
