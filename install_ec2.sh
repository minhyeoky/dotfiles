#!/bin/bash
#
# Setup EC2 environments for work.

set -e

cd $(dirname "$0")
source ./utils.sh

guard_os "Linux"

function install_vim() {
  # Install neovim.
  sudo apt remove neovim -y
  sudo add-apt-repository ppa:neovim-ppa/stable
  sudo apt update
  sudo apt install -y neovim

  # Link .vimrc.
#  backup ~/.vimrc
#  ln -s -f -v "$PWD"/vim/.vimrc ~/.vimrc
#
#  # Link .vim files. (Plugins)
#  mkdir -p -v ~/.vim
#  backup ~/.vim/.vimwiki.vim
#  ln -s -f -v "$PWD"/vim/.vimwiki.vim ~/.vim/.vimwiki.vim
#  backup ~/.vim/.coc_nvim.vim
#  ln -s -f -v "$PWD"/vim/.coc_nvim.vim ~/.vim/.coc_nvim.vim
#
#  # Link init.vim (neovim)
#  mkdir -p -v ~/.config/nvim
#  backup ~/.config/nvim/init.vim
#  ln -s -f -v "$PWD"/nvim/init.vim ~/.config/nvim/init.vim
#  
#  # Link nvim files. (Plugins)
#  backup ~/.config/nvim/coc-settings.json
#  ln -s -f -v "$PWD"/nvim/coc-settings.json ~/.config/nvim/coc-settings.json
#
#  # Install vim-plug.
#  curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
#  sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
}

    # wget -O fd.deb https://github.com/sharkdp/fd/releases/download/v8.3.0/fd_8.3.0_amd64.deb
    # sudo dpkg -i ./fd.deb
    # rm fd.deb

install_vim


    # ctags, Rg, ...
