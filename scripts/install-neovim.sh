#!/usr/bin/env bash
set -eu

archive="/tmp/nvim-linux-x86_64.tar.gz"
install_dir="/opt/nvim-linux-x86_64"

curl -fLo "$archive" \
    https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz

sudo rm -rf "$install_dir"
sudo tar -C /opt -xzf "$archive"

sudo ln -sf "$install_dir/bin/nvim" /usr/local/bin/nvim
sudo ln -sf "$install_dir/bin/nvim" /usr/local/bin/vi

rm "$archive"

nvim --version

