#!/usr/bin/env sh
# --------------------------------------------------------------------------------
# General
# --------------------------------------------------------------------------------
function watch() {
  while true; do
    clear
    date
    $*
    sleep 5
  done
}

# --------------------------------------------------------------------------------
# git
# --------------------------------------------------------------------------------
function copy_commit() {
  idx=$1
  echo "INDEX: ${idx:-0}" > /dev/null

  logs=$(git log --oneline -n 1 --skip=$idx)

  echo $logs
  echo $logs | awk '{ print $1 }' | tr -d '\n' | pbcopy
  # TODO pbcopy for linux?
}

function rebase_with_commit() {
  idx=$1

  logs=$(git log --oneline -n 1 --skip=$idx)

  echo $logs
  target=$(echo $logs | awk '{ print $1 }' | tr -d '\n')

  git fetch --all
  git reset --hard origin/staging
  git cherry-pick $target
}

# --------------------------------------------------------------------------------
# docker & docker-compose
# --------------------------------------------------------------------------------
function dc_while() {
    echo $*
    while true; do
        docker-compose $*
        sleep 2
    done
}


# --------------------------------------------------------------------------------
# Python
# --------------------------------------------------------------------------------
function cd() {
  if [[ -d ./venv ]] ; then
    deactivate
  fi

  builtin cd $1

  if [[ -d ./venv ]] ; then
    . ./venv/bin/activate
  fi
}

