#!/bin/bash

# --------------------------------------------------------------------------------
# General
# --------------------------------------------------------------------------------
function watch() {
  while true; do
    clear
    "$*"
    sleep 10
  done
}

# --------------------------------------------------------------------------------
# Python
# --------------------------------------------------------------------------------
function cd {
  if [[ -d ./venv || -d ./.venv ]]; then
    deactivate > /dev/null 2>&1
  fi

  builtin cd "$1" || exit

  if [[ -d ./venv ]]; then
    # shellcheck disable=SC1091
    source "./venv/bin/activate" && echo "Activated ${PWD}/venv"
  fi

  if [[ -d ./.venv ]]; then
    # shellcheck disable=SC1091
    source "./.venv/bin/activate" && echo "Activated ${PWD}/.venv"
  fi

  # Check if there is a environment variable file and export it.
  if [[ -f ._env ]]; then
    # shellcheck disable=SC2046
    export $(grep -v '^#' ._env | xargs) > /dev/null && echo "Exported ._env"
  fi

  # Check if there is a shell file and source it.
  if [[ -f ._bashrc ]]; then
    # shellcheck disable=SC1091
    source ._bashrc && echo "Using ._bashrc"
  fi
}
