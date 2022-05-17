#!/bin/bash

cd `dirname $0`
work_dir=${PWD}
nvim_dir=${work_dir}/nvim

_pinfo() {
    echo -e '\033[0;32m'$@'\033[0;39m'
}

_perror() {
    echo -e '\033[0;31m'$@'\033[0;39m'
}

_exit_if_failed() {
    if [ $? -ne 0 ]; then
        _perror $1
        exit 0
    fi
}

_apt_install() {
    if [ `which ${1}` ]; then
        _pinfo $1 'is already installed.'
    else
        pkg=$1
        if [ $# -eq 2 ]; then
            pkg=$2
        fi
        sudo aptitude -y install $pkg
    fi

    _exit_if_failed 'failed to install' $pkg
}

_prepare_package() {
    # for nvim-provider(clipboard)
    _apt_install xclip
    _apt_install xsel

    # for vim-plug
    _apt_install curl

    # for python interface
    _apt_install python3-pip
    pip3 install neovim
    pip3 install pynvim
    pip3 install sqlparse
}

_link() {
    if [ $XDG_CONFIG_PATH ]; then
        sudo ln -s $work_dir/nvim $XDG_CONFIG_PATH/nvim
        _exit_if_failed 'failed to create symbolic link.'
    fi
}

_install_vim_plug() {
    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

_prepare_package
_link
_install_vim_plug
