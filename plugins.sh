#!/bin/bash

cd `dirname $0`
work_dir=${PWD}
clone_dir=${work_dir}/src

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

_download() {
    mkdir -p ${clone_dir}
    git clone --recursive -j8 https://github.com/Andersbakken/rtags.git ${clone_dir}/rtags
    _exit_if_failed 'failed to fetch src.'

    git clone https://github.com/rizsotto/Bear ${clone_dir}/Bear
    _exit_if_failed 'failed to fetch src.'

    go get golang.org/x/tools/cmd/goimports
    go get -u golang.org/x/tools/cmd/gopls
}

_build() {
    cd ${clone_dir}/rtags
    LIBCLANG_LLVM_CONFIG_EXECUTABLE=llvm-config-3.9 cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_EXPORT_COMPILE_COMMANDS=1 .
    _exit_if_failed 'failed to build rtags.'
    make -j4
    _exit_if_failed 'failed to build rtags.'

    cd ${clone_dir}/Bear
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local
    _exit_if_failed 'failed to build Bear.'
    make -j4
    _exit_if_failed 'failed to build Bear.'
}

_install() {
    cd ${clone_dir}/rtags
    sudo make install
    _exit_if_failed 'failed to install rtags.'

    cd ${clone_dir}/Bear
    sudo make install
    _exit_if_failed 'failed to build Bear.'
}

_download
_build
_install
