#!/bin/bash
#
# utility functions for installation scripts.

function guard_os() {
  target_os=$1
  case "$(uname -s)" in
      Linux*)     os=Linux;;
      Darwin*)    os=Mac;;
      MSYS*)      os=Windows;;
      *)          os="UNKNOWN"
  esac
  if [[ "${os}" != "${target_os}" ]]; then
    echo "Invalid OS. target: ${target_os}"
    exit 1
  fi
}

# Create a copy of $1 in the same directory.
function backup() {
  if [[ -e $1 ]]; then
    cp -L $1 $1_backup
    echo "Backup $1 -> $1_backup"
  else
    echo "Skip backup. $1 not exists."
  fi
}
