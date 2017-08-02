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

_update() {
    cd ${src_dir}
    _exit_if_failed 'failed to move source directory.'
    git pull
    _exit_if_failed 'failed to fetch latest source.'
}

_build() {
    cd ${src_dir}
    make clean 1>/dev/null
    make CMAKE_BUILD_TYPE=Release
    _exit_if_failed 'failed to build neovim.'
}

_install() {
    cd ${src_dir}
    sudo make install
    _exit_if_failed 'failed to install neovim.'
}

_update
_build
_install
