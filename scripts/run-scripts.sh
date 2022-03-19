#!/bin/bash

set -e

BASE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

files=$(find -L "$BASE_DIR" -type f)

filenames=""
for file in $files; do
  filenames+="${file:${#BASE_DIR} + 1:${#file}} "
done

selected_filename=$(echo "${filenames}" | tr ' ' '\n' | fzf)

for file in $files; do
  filename=${file:${#BASE_DIR} + 1:${#file}}
  if [[ $filename == "$selected_filename" ]]; then 
    selected_file=$file
    break
  fi
done

. "${selected_file}"
