#!/bin/bash
#
# Setup EC2 environments for work.

set -e

cd "$(dirname "$0")"
source ./utils.sh

guard_os "Linux"

function install() {
  # Install neovim.
  sudo add-apt-repository --yes ppa:neovim-ppa/stable
  sudo apt update -y
  sudo apt --fix-broken install
  sudo apt install -y neovim

  # Install nodejs (for coc.nvim - LSP)
  curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
  sudo apt install -y nodejs
  sudo apt install -y build-essential

  # Install ctags (for tagbar)
  sudo snap install universal-ctags

  # Install Ag (for fzf)
  sudo apt install -y silversearcher-ag

  # Link init.vim (neovim)
  mkdir -p -v ~/.config
  backup ~/.config/nvim
  ln -s -f -v "$PWD"/nvim ~/.config

  # Install vim-plug.
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  sudo sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
}

install
echo "alias vim=nvim" >>~/.bashrc
. "${HOME}/.bashrc"
