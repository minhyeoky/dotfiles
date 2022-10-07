#!/bin/bash

# --------------------------------------------------------------------------------
# Aliases
# --------------------------------------------------------------------------------
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# --------------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------------
if [ -f ~/.bash_constants ]; then
    . ~/.bash_constants
fi

# --------------------------------------------------------------------------------
# Functions
# --------------------------------------------------------------------------------
if [ -f ~/.bash_functions ]; then
    . ~/.bash_functions
fi


# --------------------------------------------------------------------------------
# OS
# --------------------------------------------------------------------------------
uname_out="$(uname -s)"
case "${uname_out}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac
if [[ $uname_out == "Darwin" ]]; then
    if [[ -e ~/.bash_macosx ]]; then
        . ~/.bash_macosx
    fi
fi
# --------------------------------------------------------------------------------
# vim
# --------------------------------------------------------------------------------
export VIMRC="${HOME}/.vimrc"
export EDITOR=nvim

# fzf & fzf-vim
[ -z "$ZSH_NAME" ] && [ -f ~/.fzf.bash ] && source ~/.fzf.bash 
export FZF_COMPLETION_OPTS='--border --info=inline'
export FZF_DEFAULT_COMMAND='fd -E node_modules -E .git -E .venv --hidden --follow --type f'
# --------------------------------------------------------------------------------
# Colorize man-page
# --------------------------------------------------------------------------------
# shellcheck disable=SC2155
{
export LESS_TERMCAP_mb=$(printf '\e[01;31m') # enter blinking mode – red
export LESS_TERMCAP_md=$(printf '\e[01;35m') # enter double-bright mode – bold, magenta
export LESS_TERMCAP_me=$(printf '\e[0m') # turn off all appearance modes (mb, md, so, us)
export LESS_TERMCAP_se=$(printf '\e[0m') # leave standout mode
export LESS_TERMCAP_so=$(printf '\e[01;33m') # enter standout mode – yellow
export LESS_TERMCAP_ue=$(printf '\e[0m') # leave underline mode
export LESS_TERMCAP_us=$(printf '\e[04;36m') # enter underline mode – cyan
}

# --------------------------------------------------------------------------------
# ETC
# --------------------------------------------------------------------------------
. "$HOME/.cargo/env"
