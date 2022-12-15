# --------------------------------------------------------------------------------
# General
# --------------------------------------------------------------------------------
alias python='python3'
alias v='nvim'
alias vim='nvim'
alias g='git'
alias ll='ls -alhF'
alias tf='terraform'


# --------------------------------------------------------------------------------
# docker & docker-compose
# --------------------------------------------------------------------------------
alias rpm='dc exec web python manage.py'
alias dc='docker-compose'
alias dcp='docker-compose -f docker-compose-prod.yml'
alias webtk='dc exec web pytest -k'

# --------------------------------------------------------------------------------
# tmux & tmuxinator
# --------------------------------------------------------------------------------
alias tx=tmux

# --------------------------------------------------------------------------------
# git
# --------------------------------------------------------------------------------
alias ggh='${DOTFILES_PATH}/scripts/copy-commit-hash.sh'
alias gsrf='git secret reveal -f'
alias gshm='git secret hide -m'
alias clean_branches="git branch | grep -v "master" | xargs git branch -D"


# --------------------------------------------------------------------------------
# taskwarrior
# --------------------------------------------------------------------------------
alias t='task'
alias tA='task +ACTIVE'
alias tzk='taskzk'
alias tls='task ls'
alias tui='taskwarrior-tui'
