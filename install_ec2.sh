#!/bin/bash
#
# Setup EC2 environments for work.

set -e

cd $(dirname "$0")
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

  # Link .vimrc.
  backup ~/.vimrc
  ln -s -f -v "$PWD"/vim/.vimrc ~/.vimrc

  # Link .vim files. (Plugins)
  mkdir -p -v ~/.vim
  mkdir -p -v ~/.vim/files/info
  backup ~/.vim/.coc_nvim.vim
  ln -s -f -v "$PWD"/vim/.coc_nvim.vim ~/.vim/.coc_nvim.vim

  # Link init.vim (neovim)
  mkdir -p -v ~/.config/nvim
  backup ~/.config/nvim/init.vim
  ln -s -f -v "$PWD"/nvim/init.vim ~/.config/nvim/init.vim
  
  # Link nvim files. (Plugins)
  backup ~/.config/nvim/coc-settings.json
  ln -s -f -v "$PWD"/nvim/coc-settings.json ~/.config/nvim/coc-settings.json

  # Install vim-plug.
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  sudo sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
}

install
echo "alias vim=nvim" >> ~/.bashrc
source ~/.bashrc
