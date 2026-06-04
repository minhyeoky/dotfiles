#!/bin/bash

# --------------------------------------------------------------------------------
# General
# --------------------------------------------------------------------------------
function v() {
  if [[ -f uv.lock ]]; then
    uv run nvim "$@"
  else
    nvim "$@"
  fi
}

function watch() {
  while true; do
    clear
    "$@"
    sleep 10
  done
}
