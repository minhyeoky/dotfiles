#!/usr/bin/env bash

set -e

cd $(dirname "$0")

uname_out="$(uname -s)"
case "${uname_out}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac

function _backup() {
  if [[ -e $1 ]]; then
    cp -L $1 $1_backup
    echo "Backup $1 -> $1_backup"
  else
    echo "$1 not exists, no backup."
  fi
}

function install_vim() {
  _backup ~/.vimrc
  ln -s -f -v $PWD/vim/.vimrc ~/.vimrc

  if [[ -n $(command -v nvim) ]]; then
    echo "Skip neovim installation because already installed."
  elif [[ $uname_out == "Linux" ]]; then
    sudo apt install -y --reinstall neovim
  else
    echo "Failed to install neovim. for $uname_out"
    return 1
  fi

  mkdir -p -v ~/.config/nvim
  _backup ~/.config/nvim/init.vim
  ln -s -f -v $PWD/nvim/init.vim ~/.config/nvim/init.vim
}

function install_git() {
  _backup ~/.gitconfig
  ln -s -f -v $PWD/git/.gitconfig ~/.gitconfig

  _backup ~/.gitignore
  ln -s -f -v $PWD/git/.gitignore ~/.gitignore
}

read -p "---- Install vim? [Y/n]: " input
if [[ ${input,,} != "n" ]]; then
  install_vim
fi

read -p "---- Install git? [Y/n]: " input
if [[ ${input,,} != "n" ]]; then
  install_git
fi

