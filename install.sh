#!/bin/bash

cd `dirname $0`
work_dir=${PWD}
clone_dir=${work_dir}/src
src_dir=${clone_dir}/neovim
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
        sudo aptitude install $pkg
    fi

    _exit_if_failed 'failed to install' $pkg
}

_prepare_package() {
    _apt_install libtool libtool-bin # depends: libtool
    _apt_install automake            # depends: autoconf
    _apt_install cmake
    _apt_install pkg-config
    _apt_install unzip
    _apt_install g++
    _apt_install curl

    # for nvim-provider(clipboard)
    _apt_install xclip
    _apt_install xsel

    # for dein
    _apt_install curl

    # for python interface
    _apt_install python3-pip
    pip3 install neovim
}

_download() {
    if [ -e ${clone_dir} ]; then
        sudo rm -r ${clone_dir}
        _exit_if_failed 'failed to remove old src directory.'
    fi

    mkdir -p ${clone_dir}
    git clone https://github.com/neovim/neovim.git ${src_dir}
    _exit_if_failed 'failed to fetch src.'
}

_build() {
    cd ${src_dir}
    make clean 1>/dev/null
    make -j4 CMAKE_BUILD_TYPE=Release
    _exit_if_failed 'failed to build neovim.'
}

_install() {
    cd ${src_dir}
    sudo make install
    _exit_if_failed 'failed to install neovim.'
}

_link() {
    if [ $XDG_CONFIG_HOME ]; then
        sudo ln -s $work_dir/nvim $XDG_CONFIG_HOME/nvim
        _exit_if_failed 'failed to create symbolic link.'
    fi
}

_download_dein() {
    mkdir -p ${plugins_dir}/dein
    curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > /tmp/installer.sh
    sh /tmp/installer.sh ${nvim_dir}
}

# _pinfo 'env'
# _pinfo '  work_dir: '${work_dir}
# _pinfo '  clone_dir: '${clone_dir}
# _pinfo '  src_dir: '${src_dir}

_prepare_package
_download
_build
_install
_link
_download_dein
