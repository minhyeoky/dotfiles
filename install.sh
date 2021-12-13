#!/usr/bin/env bash

set -e

cd $(dirname "$0")

uname_out="$(uname -s)"
case "${uname_out}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    MSYS*)      machine=Windows;;
    *)          machine="UNKNOWN:${unameOut}"
esac

function _backup() {
  if [[ -e $1 ]]; then
    cp -L $1 $1_backup
    echo "Backup $1 -> $1_backup"
  else
    echo "Skip backup. $1 not exists."
  fi
}

function install_bash() {
  _backup ~/.bashrc
  ln -s -f -v $PWD/bash/.bashrc ~/.bashrc

  _backup ~/.bash_aliases
  ln -s -f -v $PWD/bash/.bash_aliases ~/.bash_aliases

  _backup ~/.bash_functions
  ln -s -f -v $PWD/bash/.bash_functions ~/.bash_functions

  _backup ~/.bash_macosx
  ln -s -f -v $PWD/bash/.bash_macosx ~/.bash_macosx
}

function install_zsh() {
  _backup ~/.zshrc
  ln -s -f -v $PWD/zsh/.zshrc ~/.zshrc

  _backup ~/.p10k.zsh
  ln -s -f -v $PWD/zsh/.p10k.zsh ~/.p10k.zsh

  if [[ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    echo "Clone zsh-syntax-highlighting done"
  fi

  if [[ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    echo "Clone zsh-autosuggestions done"
  fi

  if [[ ! -d ~/powerlevel10k ]]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
    echo "Clone powerline theme done"
  fi

  if [[ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-z ]]; then
    git clone https://github.com/agkozak/zsh-z ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-z
    echo "Clone zsh-z done"
  fi

  sudo chsh -s $(which zsh) $(whoami)
  echo "Changed default shell to zsh"
}

function install_vim() {
  _backup ~/.vimrc
  ln -s -f -v $PWD/vim/.vimrc ~/.vimrc

  if [[ -n $(command -v nvim) ]]; then
    echo "Skip neovim installation because already installed."
  elif [[ $uname_out == "Linux" ]]; then
    sudo apt install -y --reinstall neovim
  elif [[ $machine == "Windows" ]]; then
    choco install -y neovim
  else
    echo "Failed to install neovim. for $uname_out"
    return 1
  fi

  if [[ $machine == "Linux" ]]; then
    mkdir -p -v ~/.config/nvim
    _backup ~/.config/nvim/init.vim
    ln -s -f -v $PWD/nvim/init.vim ~/.config/nvim/init.vim
  elif [[ $machine == "Windows" ]]; then
    mkdir -p -v ~/AppData/Local/nvim
    _backup ~/AppData/Local/nvim/init.vim
    ln -s -f -v $PWD/nvim/init.vim ~/AppData/Local/nvim/init.vim
  else
    echo "Failed to install neovim. for $uname_out"
    return 1
  fi

  _backup ~/.config/nvim/coc-settings.json
  ln -s -f -v $PWD/nvim/coc-settings.json ~/.config/nvim/coc-settings.json

  if [[ -n $(command -v fd) ]]; then
    echo "Skip fd installation because already installed."
  elif [[ $uname_out == "Linux" ]]; then
    # TODO ARM
    wget -O fd.deb https://github.com/sharkdp/fd/releases/download/v8.3.0/fd_8.3.0_amd64.deb
    sudo dpkg -i ./fd.deb
    rm fd.deb
  elif [[ $machine == "Windows" ]]; then
    choco install -y fd
  else
    echo "Failed to install fd. for $uname_out"
    return 1
  fi

  if [[ -n $(command -v rg) ]]; then
    echo "Skip rg installation because already installed."
  elif [[ $machine == "Linux" ]]; then
    echo "TODO"
    return 1
  elif [[ $machine == "Windows" ]]; then
    choco install -y ripgrep
  else
    echo "Failed to install fd. for $uname_out"
    return 1
  fi

  # Install ctags.
  if [[ -n $(command -v ctags) ]]; then
    echo "Skip ctags installation because already installed."
  elif [[ $uname_out == "Linux" ]]; then
    # TODO ARM
    sudo apt install -y ctags
  elif [[ $machine == "Windows" ]]; then
    choco install -y ctags
  else
    echo "Failed to install fd. for $uname_out"
    return 1
  fi
}

function install_git() {
  _backup ~/.gitconfig
  ln -s -f -v $PWD/git/.gitconfig ~/.gitconfig

  _backup ~/.gitignore
  ln -s -f -v $PWD/git/.gitignore ~/.gitignore
}

read -p "---- Install bash? [Y/n]: " input
if [[ ${input} != "n" ]]; then
  install_bash
fi

read -p "---- Install zsh? [Y/n]: " input
if [[ ${input} != "n" ]]; then
  install_zsh
fi

read -p "---- Install vim? [Y/n]: " input
if [[ ${input} != "n" ]]; then
  install_vim
fi

read -p "---- Install git? [Y/n]: " input
if [[ ${input} != "n" ]]; then
  install_git
fi

