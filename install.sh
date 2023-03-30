#!/bin/bash
# vim: tw=0
# curl https://raw.githubusercontent.com/nim65s/scripts/master/install.sh | bash

set -e
set -x

cd

mkdir -p .config .ssh .gnupg
chmod 700 .ssh .gnupg
touch .gitrepos .ssh/authorized_keys

[[ -f /etc/arch-release ]]   && sudo pacman -Syu --noconfirm --needed git gvim fish openssh tinc python-pip rofi pass pcsc-tools ccid libusb-compat dunst msmtp-mta shellcheck dfc ripgrep fd khal khard vdirsyncer todoman ncdu bat htop tig inetutils kitty iwd rustup git-delta watchexec docker-compose python-wheel python-i3ipc python-pandocfilters ipython just bacon
[[ -f /etc/debian_version ]] && sudo apt install -qqy gnupg2 terminator git vim tinc pcscd libpcsclite1 pcsc-tools scdaemon python3-pip msmtp-mta shellcheck dfc wget libpcre2-8-0 lsb-release bc gettext-base man-db khal khard vdirsyncer todoman tig
command -v yum && sudo yum install git fish vim tinc python3-pip gcc

if [[ -z "$SSH_CLIENT" ]]
then
    echo enable-ssh-support > .gnupg/gpg-agent.conf
    {
        echo use-agent
        echo default-key 7D2ACDAF4653CF28
        echo personal-digest-preferences SHA256
        echo cert-digest-algo SHA256
        echo default-preference-list SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed
    } > .gnupg/gpg.conf

    gpg-connect-agent reloadagent /bye

    # Check Key
    gpg2 --card-status
    curl https://github.com/nim65s.gpg | gpg --import
    rm -f /tmp/secret{,.gpg}
    echo 'IT WORKS \o/' > /tmp/secret
    gpg --encrypt --trusted-key 7D2ACDAF4653CF28 -r 7D2ACDAF4653CF28 /tmp/secret
    gpg --decrypt /tmp/secret.gpg
fi

SSH_AUTH_SOCK=$(gpgconf --list-dir | grep agent-ssh-socket | cut -d: -f2)
export SSH_AUTH_SOCK
grep -q cardno:000605255506 .ssh/authorized_keys || ssh-add -L >> .ssh/authorized_keys

ssh-keyscan github.com | ssh-keygen -lf - >> .ssh/known_hosts

for repo in dotfiles scripts VPNim
do
    test -d $repo || git clone --recursive git@github.com:nim65s/$repo.git
    pushd $repo
    git pull --rebase
    git submodule update --recursive --remote --rebase --init
    # shellcheck disable=SC2016
    git submodule foreach -q --recursive 'git checkout $(git config -f $toplevel/.gitmodules submodule.$name.branch || echo master)'
    grep -q $repo ~/.gitrepos || pwd >> ~/.gitrepos
    popd
done

for file in .bash_profile .bash_logout .tmux.conf .nanorc .vimpagerrc .vimrc .Xdefaults .gitconfig .bashrc .hgrc .zshrc .xmonad .vim .xinitrc .compton.conf .editorconfig .ipython .imapfilter .notmuch-config .msmtprc .pypirc .latexmk .
do
    [[ -L $file || -f $file ]] && rm $file
    ln -s "$HOME/dotfiles/$file" .
done

cd ~/.config
for files in awesome dfc fish pep8 ranger terminator zathura flake8 terminology fontconfig khal khard vdirsyncer todoman offlineimap mutt i3 i3status rofi dunst pylintrc yapf picom bat kitty sway gtk-3.0 zellij starship.toml
do
    [[ -L $files ]] && rm $files
    ln -s "$HOME/dotfiles/.config/$files" .
done
cd

python3 -m pip install -U --user pip
python3 -m pip install -U --user pygments_zenburn

if command -v rustup > /dev/null
then
    rustup default || rustup default nightly
    cargo install cargo-binstall
    [[ -f /etc/debian_version ]] && cargo binstall fd-find ripgrep zellij just bacon
fi

grep "$USER" /etc/passwd | grep -q fish || echo "chsh -s $(grep fish /etc/shells)"
