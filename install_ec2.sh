#!/bin/bash
#
# Setup EC2 environments for work.

set -e

cd $(dirname "$0")
source ./utils.sh

guard_os "Linux"

    # wget -O fd.deb https://github.com/sharkdp/fd/releases/download/v8.3.0/fd_8.3.0_amd64.deb
    # sudo dpkg -i ./fd.deb
    # rm fd.deb

    # sudo apt remove neovim -y
    # sudo add-apt-repository ppa:neovim-ppa/stable
    # sudo apt update
    # sudo apt install -y neovim



    # ctags, Rg, ...
