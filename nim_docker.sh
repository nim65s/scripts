#!/bin/bash
# vim: tw=0
# curl https://raw.githubusercontent.com/nim65s/scripts/master/nim_docker.sh | bash && fish
# NB: vipe is in moreutils

set -ex

FD_VERSION=8.4.0
RG_VERSION=13.0.0
BAT_VERSION=0.20.0
DELTA_VERSION=0.12.1

if [[ $(id -u) == 0 ]]
then
    SUDO=''
else
    SUDO=sudo
fi

[[ -f /etc/alpine-release ]] && $SUDO apk add                                   vim htop ncdu git tig gnupg  fish fd
[[ -f /etc/arch-release ]]   && $SUDO pacman -Syu --noconfirm                   vim htop ncdu git tig gnupg  fish fd dfc ripgrep bat
[[ -f /etc/fedora-release ]] && $SUDO dnf install -y                            vim htop ncdu git tig gnupg  fish        ripgrep
[[ -f /etc/debian_version ]] && $SUDO apt update -qqy && $SUDO apt install -qqy vim htop ncdu git tig gnupg2         dfc         wget libpcre2-8-0 lsb-release bc gettext-base man-db software-properties-common
if [[ -f /etc/debian_version ]]
then
    FD="https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd_${FD_VERSION}_amd64.deb"
    RG="https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep_${RG_VERSION}_amd64.deb"
    BAT="https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/bat_${BAT_VERSION}_amd64.deb"
    DELTA="https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/git-delta-musl_${DELTA_VERSION}_amd64.deb"
    wget "$FD" "$RG" "$BAT" "$DELTA"

    DEBIAN_VERSION=$(lsb_release -cs)
    if [[ ${DEBIAN_VERSION} == buster || ${DEBIAN_VERSION} == focal ]]
    then
        $SUDO apt install -qqy fish
    elif [[ ${DEBIAN_VERSION} != stretch ]]
    then
        $SUDO apt-add-repository "ppa:fish-shell/release-3"
        $SUDO apt update -qqy
        $SUDO apt install fish -qqy
    fi

    $SUDO dpkg -i ./{fd,bat,git-delta}*.deb
    $SUDO dpkg-divert --add --divert /usr/share/fish/completions/rg.fish.0 --rename --package ripgrep /usr/share/fish/completions/rg.fish
    $SUDO dpkg -i ./ripgrep*.deb
    rm ./*.deb
elif [[ -f /etc/fedora-release ]]
then
    echo -e '#!/bin/sh\ncat /etc/hostname' > /usr/local/bin/hostname
    chmod +x /usr/local/bin/hostname
fi

cd
git clone --depth 1 https://github.com/nim65s/dotfiles.git
cd dotfiles
git submodule update --init Zenburn vim-plug bass

cd
for file in .bash_profile .bash_logout .tmux.conf .nanorc .vimrc .Xdefaults .gitconfig .bashrc .hgrc .zshrc .xmonad .vim .xinitrc .compton.conf .editorconfig .ipython .imapfilter .notmuch-config .msmtprc .pypirc
do
    [[ -L $file || -f $file ]] && rm $file
    ln -s "$HOME/dotfiles/$file" .
done

mkdir -p .config
cd .config
for files in dfc fish pep8 ranger zathura flake8 pylintrc
do
    [[ -L $files ]] && rm $files
    ln -s "$HOME/dotfiles/.config/$files" .
done
