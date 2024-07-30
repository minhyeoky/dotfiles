# --------------------------------------------------------------------------------
# General
# --------------------------------------------------------------------------------
alias python='python3'
alias v='nvim'
alias vim='nvim'
alias g='git'
alias ll='ls -alhF'
alias tf='terraform'
alias qmkf='qmk flash --keyboard crkbd --keymap minhyeoky'
alias po=poetry
alias mp='multipass'
alias mk=microk8s
alias k='microk8s kubectl'
alias j='jira'
alias ldg='ledger'
alias vl='vim ${LEDGER_FILE}'
alias e='emacs -nw'

# GitHub Copilot CLI
alias explain='gh copilot explain'
alias suggest='gh copilot suggest'


# --------------------------------------------------------------------------------
# docker & docker-compose
# --------------------------------------------------------------------------------
alias dc='docker compose'

# --------------------------------------------------------------------------------
# git
# zsh alias: https://kapeli.com/cheat_sheets/Oh-My-Zsh_Git.docset/Contents/Resources/Documents/index
# --------------------------------------------------------------------------------
alias ggh='${DOTFILES_PATH}/scripts/copy-commit-hash.sh'
alias gbd='git branch -d'
alias gbd!='git branch -D'
alias grh='git reset'
alias grhh='git reset --hard'
alias gdt='git difftool'
alias gaa='git add --all'
alias gfa='git fetch --all --prune'
alias gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign -m "wip"'
alias gst='git status'
alias gcm='git checkout master'
alias gca='git commit -v -a'
alias gca!='git commit -v -a --amend'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcp='git cherry-pick'
alias gsrf='git secret reveal -f'
alias gshm='git secret hide -m'
#alias clean_branches="git branch | grep -v "master" | xargs git branch -D"
