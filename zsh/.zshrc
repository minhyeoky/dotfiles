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
  fzf-tab
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
# FZF
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

# --------------------------------------------------------------------------------
# TMUX
# --------------------------------------------------------------------------------
export DISABLE_AUTO_TITLE='true'


# --------------------------------------------------------------------------------
# NEOVIM
# --------------------------------------------------------------------------------
export MANPAGER='nvim +Man!'
export NVIM_APPNAME=

# fzf-tab
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

# --------------------------------------------------------------------------------
# CLAUDE CODE
# --------------------------------------------------------------------------------
alias cc='claude --verbose --dangerously-skip-permissions --plugin-dir $HOME/minhyeoky.github.io/claude-plugin'

# --------------------------------------------------------------------------------
# DIRENV
# --------------------------------------------------------------------------------
eval "$(direnv hook zsh)"

# --------------------------------------------------------------------------------
# EMACS
# --------------------------------------------------------------------------------
e() {
  emacsclient -e nil &>/dev/null || emacs --daemon &>/dev/null
  emacsclient -nw "$@"
}
alias ek='emacsclient -e "(kill-emacs)"'

# --------------------------------------------------------------------------------
# ETC
# --------------------------------------------------------------------------------

# Source local zshrc if it exists (overrides and customizations)
if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
fi
