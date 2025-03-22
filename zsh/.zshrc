# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --------------------------------------------------------------------------------
# BASIC CONFIGURATION
# --------------------------------------------------------------------------------
# Source bashrc if it exists
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# Language environment
export LANG=en_US.UTF-8

# Enable vi mode in the shell
set -o vi

# --------------------------------------------------------------------------------
# OH-MY-ZSH CONFIGURATION
# --------------------------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

DISABLE_MAGIC_FUNCTIONS=true

# Plugins
plugins=(
  zsh-autosuggestions
  zsh-syntax-highlighting
  tmux
  docker
  docker-compose
  fasd
  git
  z
)


source $ZSH/oh-my-zsh.sh

# --------------------------------------------------------------------------------
# PATH CONFIGURATION
# --------------------------------------------------------------------------------
# Add directories to PATH
export PATH="$HOME/.local/bin:$PATH"

# --------------------------------------------------------------------------------
# DEVELOPMENT TOOLS
# --------------------------------------------------------------------------------
# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# SDKMAN
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# SCM Breeze
[ -s "~/.scm_breeze/scm_breeze.sh" ] && source "~/.scm_breeze/scm_breeze.sh"

# FZF
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

# --------------------------------------------------------------------------------
# TMUX
# --------------------------------------------------------------------------------
export DISABLE_AUTO_TITLE='true'

# --------------------------------------------------------------------------------
# MCP
# --------------------------------------------------------------------------------
export MCP_HUB_CONFIG_PATH="$HOME/mcpservers.json"


# --------------------------------------------------------------------------------
# NEOVIM
# --------------------------------------------------------------------------------
export MANPAGER='nvim +Man!'
export NVIM_PYTHON3_HOST_PROG="$HOME/.pyenv/shims/python3.11"
export NVIM_APPNAME="minhyeoky"

# --------------------------------------------------------------------------------
# POWERLEVEL10K
# --------------------------------------------------------------------------------
# Local p10k configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
# Dropbox p10k configuration
[[ ! -f ~/Library/CloudStorage/Dropbox/box/dotfiles/zsh/.p10k.zsh ]] || source ~/Library/CloudStorage/Dropbox/box/dotfiles/zsh/.p10k.zsh


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
eval "$(uv generate-shell-completion zsh)"
