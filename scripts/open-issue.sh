#!/usr/bin/env bash
# Open an issue / PR / MR of the current repo in the browser, by number.
#
# Usage:
#   open-issue.sh [ref]      ref: 192 (issue) | '#192' (issue) | '!192' (PR/MR)
#   open-issue.sh -n [ref]   print the URL instead of opening it
#   open-issue.sh            no arg -> prompt for ref (this is how the
#                            run-scripts.sh fzf picker invokes it)
#
# 번호를 이미 아는 경우의 primitive다. 번호를 모를 때는 pick-issue.sh 가 목록을
# 보여주고, 고른 결과를 이 스크립트에 넘긴다.
#
# GitHub은 issue와 PR이 번호 공간을 공유하고 /issues/N 이 PR이면 /pull/N 으로
# 리다이렉트되므로 접두사 없이 번호만 줘도 맞는 곳에 도착한다. GitLab은 issue와
# MR이 번호 공간을 따로 쓰므로 !N 으로 MR을 명시해야 한다.
#
# zsh에서는 '#'(interactive_comments)과 '!'(history expansion) 둘 다 셸이 먼저
# 먹으므로 반드시 따옴표로 감싼다. 접두사 없는 순수 번호만 그냥 써도 된다.
# tmux command-prompt 나 popup 경유는 셸이 개입하지 않아 따옴표가 필요 없다.
#
# gh/glab 같은 외부 CLI나 토큰에 의존하지 않는다 — remote URL만으로 웹 URL을
# 조립하므로 사내 GitLab에서도 설정 없이 그대로 동작한다.
set -euo pipefail

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/forge-lib.sh"

DRY=0
if [ "${1:-}" = "-n" ]; then
  DRY=1
  shift
fi

ref="${1:-}"
if [ -z "$ref" ]; then
  read -r -p "issue/MR #: " ref
fi

forge_parse_ref "$ref"
forge_load

target="$(forge_url "$FORGE_REF_KIND" "$FORGE_REF_NUM")"

if [ "$DRY" = 1 ]; then
  echo "$target"
elif command -v open >/dev/null 2>&1; then
  open "$target"
elif command -v xdg-open >/dev/null 2>&1; then
  xdg-open "$target"
else
  echo "브라우저를 열 수 없어 URL만 출력합니다." >&2
  echo "$target"
fi
