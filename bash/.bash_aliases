# --------------------------------------------------------------------------------
# GENERAL ALIASES
# --------------------------------------------------------------------------------
alias v='nvim'
alias vim='nvim'
alias ll='ls -alhF'

# --------------------------------------------------------------------------------
# DEVELOPMENT TOOLS
# --------------------------------------------------------------------------------
alias g='git'
alias po='poetry'
alias k='kubectl'
alias dc='docker compose'

# --------------------------------------------------------------------------------
# GIT ALIASES
# Reference: https://kapeli.com/cheat_sheets/Oh-My-Zsh_Git.docset/Contents/Resources/Documents/index
# --------------------------------------------------------------------------------
# Branch management
alias gbd='git branch -d'                # Delete branch (safe)
alias gbd!='git branch -D'               # Force delete branch
alias gcb='git checkout -b'              # Create and checkout new branch
alias gcm='git checkout master'          # Checkout master branch
alias gco='git checkout'                 # Checkout branch

# Status and information
alias ggh='${DOTFILES_DIR}/scripts/copy-commit-hash.sh'  # Copy commit hash
alias gst='git status'                   # Show status

# Working with changes
alias gaa='git add --all'                # Add all changes
alias gca='git commit -v -a'             # Commit all changes
alias gca!='git commit -v -a --amend'    # Amend last commit
alias gcp='git cherry-pick'              # Cherry-pick commits
alias gdt='git difftool'                 # Open diff tool
alias grh='git reset'                    # Reset changes
alias grhh='git reset --hard'            # Hard reset changes

# Remote operations
alias gfa='git fetch --all --prune'      # Fetch all and prune

# Workflow helpers
alias gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign -m "wip"'  # Save work-in-progress

# Git Secret
alias gsrf='git secret reveal -f'        # Reveal secret files
alias gshm='git secret hide -m'          # Hide modified files
