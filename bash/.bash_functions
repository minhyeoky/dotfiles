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
    deactivate && echo "Deactivated python virtualen. (venv or .venv)"
  fi

  builtin cd "$1"

  if [[ -d ./venv ]]; then
    . "${PWD}/venv/bin/activate" && echo "Activated ${PWD}/venv"
  fi

  if [[ -d ./.venv ]]; then
    . "${PWD}/.venv/bin/activate" && echo "Activated ${PWD}/.venv"
  fi
}
