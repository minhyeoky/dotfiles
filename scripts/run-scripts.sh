#!/bin/bash

set -e

BASE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# 메뉴에 띄우지 않을 스크립트는 자기 헤더에 '# no-menu' 한 줄을 적는다. 디렉토리로
# 가르지 않는 이유는 분류가 겹치기 때문 — 키가 있는 것, alias 가 있는 것, 설치성인
# 것이 서로 배타적이지 않아 매번 소속을 다시 판단해야 한다. 파일이 스스로 빠지게
# 하면 애매한 것들은 판단 없이 그냥 보이면 된다.
files=$(find -L "$BASE_DIR" -type f ! -name "$(basename "$0")" -print0 \
  | xargs -0 grep -LxF '# no-menu')

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
