#!/usr/bin/env bash
set -eu

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source_dir="$repo_dir/nvim"

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
data_home="${XDG_DATA_HOME:-$HOME/.local/share}"

config_dir="$config_home/nvim"
plug_path="$data_home/nvim/site/autoload/plug.vim"

if [ -e "$config_dir" ] || [ -L "$config_dir" ]; then
    if [ ! -L "$config_dir" ] || [ "$(readlink -f "$config_dir")" != "$source_dir" ]; then
        echo "$config_dir already exists and does not point to $source_dir." >&2
        exit 1
    fi
else
    mkdir -p "$(dirname "$config_dir")"
    ln -s "$source_dir" "$config_dir"
fi

if [ ! -f "$plug_path" ]; then
    mkdir -p "$(dirname "$plug_path")"

    curl -fLo "$plug_path" \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

echo "Neovim configuration installed."
echo "Run :PlugInstall in Neovim."

