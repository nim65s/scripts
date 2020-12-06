#!/bin/bash
# vim: tw=0
# curl https://raw.githubusercontent.com/nim65s/scripts/master/nim_docker.sh | bash && fish
# NB: vipe is in moreutils

set -ex

FD_VERSION=8.2.0
RG_VERSION=12.1.1
BAT_VERSION=0.16.0
DELTA_VERSION=0.4.4
FISH_VERSION=3.1.2

if [[ $(id -u) == 0 ]]
then
    SUDO=''
else
    SUDO=sudo
fi

[[ -f /etc/alpine-release ]] && $SUDO apk add                             vim htop ncdu git tig gnupg  fish fd
[[ -f /etc/arch-release ]]   && $SUDO pacman -Syu --noconfirm             vim htop ncdu git tig gnupg  fish fd dfc ripgrep bat
[[ -f /etc/fedora-release ]] && $SUDO dnf install -y                      vim htop ncdu git tig gnupg  fish        ripgrep
[[ -f /etc/debian_version ]] && $SUDO apt update -qqy && apt install -qqy vim htop ncdu git tig gnupg2         dfc         wget libpcre2-8-0 lsb-release bc gettext-base man-db
if [[ -f /etc/debian_version ]]
then
    FD="https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd_${FD_VERSION}_amd64.deb"
    RG="https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep_${RG_VERSION}_amd64.deb"
    BAT="https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/bat_${BAT_VERSION}_amd64.deb"
    DELTA="https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/git-delta_${DELTA_VERSION}_amd64.deb"
    wget "$FD" "$RG" "$BAT" "$DELTA"

    DEBIAN_VERSION=$(lsb_release -cs)
    if [[ ${DEBIAN_VERSION} == buster || ${DEBIAN_VERSION} == focal ]]
    then
        apt install -qqy fish
    elif [[ ${DEBIAN_VERSION} != stretch ]]
    then
        FISH="https://launchpad.net/~fish-shell/+archive/ubuntu/release-3/+files/fish_${FISH_VERSION}-1~${DEBIAN_VERSION}_amd64.deb"
        FISH_COMMON="https://launchpad.net/~fish-shell/+archive/ubuntu/release-3/+files/fish-common_${FISH_VERSION}-1~${DEBIAN_VERSION}_all.deb"
        wget "$FISH" "$FISH_COMMON"
        dpkg -i ./fish*.deb
    fi

    dpkg -i ./{fd,bat,git-delta}*.deb
    dpkg-divert --add --divert /usr/share/fish/completions/rg.fish.0 --rename --package ripgrep /usr/share/fish/completions/rg.fish
    dpkg -i ./ripgrep*.deb
    rm ./*.deb
fi

cd
git clone --depth 1 https://github.com/nim65s/dotfiles.git
cd dotfiles
git submodule update --init Zenburn vim-plug submodules/docker-fish-completion

cd
for file in .bash_profile .bash_logout .tmux.conf .nanorc .vimrc .Xdefaults .gitconfig .bashrc .hgrc .zshrc .xmonad .vim .xinitrc .compton.conf .editorconfig .ipython .imapfilter .notmuch-config .msmtprc .pypirc
do
    [[ -L $file || -f $file ]] && rm $file
    ln -s "$HOME/dotfiles/$file" .
done

mkdir -p .config
cd .config
for files in awesome dfc fish pep8 ranger terminator zathura flake8 terminology fontconfig khal khard vdirsyncer todoman offlineimap mutt i3 i3status rofi dunst pylintrc
do
    [[ -L $files ]] && rm $files
    ln -s "$HOME/dotfiles/.config/$files" .
done
