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
  git
  z
  fzf-tab
)

source "$ZSH/oh-my-zsh.sh"

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

# fzf-tab
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

# --------------------------------------------------------------------------------
# TMUX
# --------------------------------------------------------------------------------
export DISABLE_AUTO_TITLE='true'

# --------------------------------------------------------------------------------
# NEOVIM
# --------------------------------------------------------------------------------
export MANPAGER='nvim +Man!'

# --------------------------------------------------------------------------------
# CLAUDE CODE
# --------------------------------------------------------------------------------
alias c='claude --dangerously-skip-permissions --model "sonnet[1m]" --effort medium'
alias cc='claude --dangerously-skip-permissions --model "opus[1m]" --effort high'
alias cr='claude remote-control --permission-mode "bypassPermissions" --spawn "same-dir"'

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
# KEYBINDINGS
# --------------------------------------------------------------------------------
# Edit command line in $EDITOR with Ctrl+X, Ctrl+E
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M viins '^X^E' edit-command-line
bindkey -M vicmd '^X^E' edit-command-line

# --------------------------------------------------------------------------------
# ETC
# --------------------------------------------------------------------------------
# dotfiles-guard: warn loudly if a repo ships .githooks but they aren't active here
_dotfiles_guard_check() {
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) || return
  [[ -d "$root/.githooks" ]] || return
  [[ "$(git config core.hooksPath 2>/dev/null)" == ".githooks" ]] && return
  print -P "%F{red}⚠ dotfiles-guard 비활성%f — secret/PII 훅이 꺼져 있습니다. %F{yellow}./.githooks/install.sh%f 실행."
}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd _dotfiles_guard_check
_dotfiles_guard_check

# Source local zshrc if it exists (overrides and customizations)
if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
fi
