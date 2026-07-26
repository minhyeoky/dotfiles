#!/bin/bash

set -e

BASE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# *-lib.sh 는 다른 스크립트가 source 하는 라이브러리라 고를 대상이 아니다.
files=$(find -L "$BASE_DIR" -type f ! -name "$(basename "$0")" ! -name '*-lib.sh')

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
