#!/bin/bash

# --------------------------------------------------------------------------------
# General
# --------------------------------------------------------------------------------
function watch() {
  while true; do
    clear
    "$*"
    sleep 1
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

  # Check if there is a .auto_env file and export it.
  if [[ -f .auto_env ]]; then
    # shellcheck disable=SC2046
    export $(grep -v '^#' .auto_env | xargs) > /dev/null && echo "Exported .env_auto"
  fi

  # Check if there is a .localrc file and source it.
  if [[ -f .localrc ]]; then
    # shellcheck disable=SC1091
    source .localrc && echo "Sourced .localrc"
  fi
}
