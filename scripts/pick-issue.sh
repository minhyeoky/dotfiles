#!/usr/bin/env bash
# Pick an open issue/PR/MR from a list and open it in the browser.
#
# Usage:
#   pick-issue.sh        fzf over open items; pick one, or type any number
#   pick-issue.sh -n     print the URL instead of opening it
#
# Meant to run inside a tmux popup:
#   bind-key g display-popup -E -d '#{pane_current_path}' -w 80% -h 60% \
#     -T ' issue/MR ' "$HOME/dotfiles/scripts/pick-issue.sh"
#
# 번호를 아는 경우는 open-issue.sh 로 충분하다. 이 스크립트는 번호를 모를 때
# 목록에서 고르게 하고, 고른 ref 를 open-issue.sh 에 넘긴다.
#
# fzf 질의를 그대로 번호 폴백으로 쓴다 — 목록에 없는 것(닫힌 issue, 다른 번호)을
# 타이핑하면 매치가 없어도 그 번호로 직행한다. 그래서 목록을 못 가져오는 상황
# (gh 미설치·미인증, GITLAB_TOKEN 없음, API 장애)에서도 최소 기능은 유지된다.
# 목록 조회는 전부 fail-open — 실패하면 조용히 빈 목록이 되고 번호 입력으로 걷긴다.
#
# GitLab은 API 목록에 project-scoped 번호인 iid 를 쓴다 (전역 id 가 아니다).
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/forge-lib.sh"

# -n 은 그대로 open-issue.sh 에 넘긴다 (열지 않고 URL만 출력).
DRY=()
if [ "${1:-}" = "-n" ]; then
  DRY=(-n)
  shift
fi

forge_load

list_github() {
  command -v gh >/dev/null 2>&1 || return 0
  gh issue list --limit 50 --json number,title \
    --jq '.[] | "#\(.number)\t\(.title)"' 2>/dev/null || true
  gh pr list --limit 50 --json number,title \
    --jq '.[] | "!\(.number)\t\(.title)"' 2>/dev/null || true
}

list_gitlab() {
  [ -n "${GITLAB_TOKEN:-}" ] || return 0
  command -v jq >/dev/null 2>&1 || return 0
  local api proj
  api="https://${FORGE_WEB_HOST}/api/v4"
  proj="$(printf '%s' "$FORGE_PATH" | jq -sRr '@uri')"
  curl -sf --connect-timeout 2 --max-time 6 -H "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
    "${api}/projects/${proj}/issues?state=opened&per_page=50" 2>/dev/null |
    jq -r '.[] | "#\(.iid)\t\(.title)"' 2>/dev/null || true
  curl -sf --connect-timeout 2 --max-time 6 -H "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
    "${api}/projects/${proj}/merge_requests?state=opened&per_page=50" 2>/dev/null |
    jq -r '.[] | "!\(.iid)\t\(.title)"' 2>/dev/null || true
}

if [ "$FORGE_KIND" = "github" ]; then
  rows="$(list_github | awk -F'\t' 'NF{printf "%-7s %s\n", $1, $2}')"
else
  rows="$(list_gitlab | awk -F'\t' 'NF{printf "%-7s %s\n", $1, $2}')"
fi

if [ -z "$rows" ]; then
  # 목록이 없으면 fzf를 띄울 이유가 없다 — 번호만 받는다.
  read -r -p "issue/MR #: " ref
else
  # --no-extended --exact 로 질의를 리터럴 substring 으로 고정한다. 기본 모드에서는
  # '!' 가 fzf 의 부정 연산자라 '!192' 가 "192 없는 행"을 뜻해 엉뚱한 행이 선택되고,
  # fuzzy 매칭은 '!192' 를 '!197 ... 2026' 처럼 흩어진 문자에도 매치시킨다.
  # 둘 다 번호 폴백을 조용히 삼키는 경로다.
  rc=0
  out="$(printf '%s\n' "$rows" | fzf \
    --print-query --no-multi --reverse --no-extended --exact \
    --prompt='issue/MR> ' \
    --header="${FORGE_PATH}  (목록에 없으면 번호를 직접 입력)")" || rc=$?

  # Esc / Ctrl-C 는 취소. rc 1 은 "매치 없음" 이라 번호 폴백으로 넘긴다.
  [ "$rc" = 130 ] && exit 0

  query="$(printf '%s\n' "$out" | sed -n 1p)"
  sel="$(printf '%s\n' "$out" | sed -n 2p)"

  if [ -n "$sel" ]; then
    ref="${sel%% *}"
  elif [ -n "$query" ]; then
    ref="$query"
  else
    exit 0
  fi
fi

# ${DRY[@]+...} 형태여야 한다 — bash 3.2 는 set -u 에서 빈 배열의 "${A[@]}" 를
# unbound variable 로 죽인다 (회사 머신에 homebrew bash 가 없을 수 있다).
exec "$DIR/open-issue.sh" ${DRY[@]+"${DRY[@]}"} "$ref"
