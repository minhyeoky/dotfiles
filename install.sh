#!/usr/bin/env bash
#
# Install dotfiles for Mac OSX.


set -e

cd $(dirname "$0")
source ./utils.sh

guard_os "Mac"

function install_bash() {
  backup ~/.bashrc
  ln -s -f -v "$PWD"/bash/.bashrc ~/.bashrc

  backup ~/.bash_aliases
  ln -s -f -v "$PWD"/bash/.bash_aliases ~/.bash_aliases

  backup ~/.bash_functions
  ln -s -f -v "$PWD"/bash/.bash_functions ~/.bash_functions

  backup ~/.bash_macosx
  ln -s -f -v "$PWD"/bash/.bash_macosx ~/.bash_macosx
}

function install_zsh() {
  backup ~/.zshrc
  ln -s -f -v "$PWD"/zsh/.zshrc ~/.zshrc

  backup ~/.p10k.zsh
  ln -s -f -v "$PWD"/zsh/.p10k.zsh ~/.p10k.zsh

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
}

function install_vim() {
  # Install neovim.
  brew update
  brew install neovim --HEAD

  # Link .vimrc.
  backup ~/.vimrc
  ln -s -f -v "$PWD"/vim/.vimrc ~/.vimrc

  # Link .vim files. (Plugins)
  mkdir -p -v ~/.vim
  backup ~/.vim/.vimwiki.vim
  ln -s -f -v "$PWD"/vim/.vimwiki.vim ~/.vim/.vimwiki.vim
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
  sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  
  # Install ripgrep, fd.
  brew install ripgrep
  brew install fd
}

function install_git() {
  backup ~/.gitconfig
  ln -s -f -v "$PWD"/git/.gitconfig ~/.gitconfig

  backup ~/.gitignore
  ln -s -f -v "$PWD"/git/.gitignore ~/.gitignore
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

