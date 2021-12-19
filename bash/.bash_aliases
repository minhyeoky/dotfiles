# --------------------------------------------------------------------------------
# General
# --------------------------------------------------------------------------------
alias python='python3'
alias v='nvim'
alias vim='nvim'
alias g='git'
alias ll='ls -alhF'

# --------------------------------------------------------------------------------
# docker & docker-compose
# --------------------------------------------------------------------------------
alias rpm='dc exec web python manage.py'
alias dc='docker-compose'
alias dcp='docker-compose -f docker-compose-prod.yml'

# --------------------------------------------------------------------------------
# tmux & tmuxinator
# --------------------------------------------------------------------------------
alias tx=tmux
alias mux=tmuxinator

# --------------------------------------------------------------------------------
# git
# --------------------------------------------------------------------------------
alias ggh='~/scripts/copy_git_log_hash.sh'

# --------------------------------------------------------------------------------
# buku - bookmark manager
# --------------------------------------------------------------------------------
alias b='buku --suggest'
alias bw='buku -w'  # create or update

# --------------------------------------------------------------------------------
# Task & Time
# --------------------------------------------------------------------------------
alias t='task'
alias tt='task due:today'
