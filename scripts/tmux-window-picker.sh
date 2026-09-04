#!/bin/bash
# window·pane 목록을 미리보기와 함께 고른다 — 미리보기는 오른쪽에 선다.
#
# tmux 내장 choose-tree(prefix + s)는 미리보기를 항상 목록 아래에 그린다
# (mode-tree.c 가 y 좌표를 `sy - h` 로 박아 놓았고 위치를 바꾸는 옵션도 포맷도
# 없다). 오른쪽 미리보기가 필요해서 목록을 fzf 로 다시 짰다.
#
# 행은 "어디서 무엇이 돌고 있나"로 읽는다: 좌표 · 디렉토리 · 마지막 활동 · 제목.
# 제목은 pane_title 이라 claude 처럼 제목을 갱신하는 프로그램은 현재 작업이 뜨고,
# 갱신하지 않는 셸은 pane_title 이 호스트명이라 window 이름으로 떨어뜨린다.
#
# display-popup -E 안에서 돌므로 popup 을 띄운 client 를 그대로 조작한다.
# client 가 여럿 붙어 있으면 switch-client 대상은 tmux 가 고른 현재 client 다.
#
# 사용: tmux-window-picker.sh
#   내부 호출: --windows | --panes (fzf reload 용) · --toggle (tab 키 액션)

set -u

# fzf 가 reload·transform 으로 이 스크립트를 다시 부르므로 경로가 절대여야 한다.
self=$(cd -- "$(dirname -- "$0")" && pwd)/$(basename -- "$0")

# 컬럼 폭은 tmux 의 p 패딩이 잡는다 — 그쪽은 글자 수가 아니라 표시 폭으로 세서
# 한글 window 이름이 섞여도 안 밀린다. 반대로 =/N/ 잘라내기는 글자 수라 둘을
# 같은 컬럼에 겹쳐 쓰면 단위가 어긋난다. 그래서 폭이 예측 불가능한 제목은
# 아예 마지막에 두고 자르지 않는다 — 넘치면 화면 끝에서 잘릴 뿐 다음 컬럼이 없다.
# 좌표와 디렉토리는 인덱스·경로라 ASCII 로 보고 잘라도 안전하다.
TARGET_W=12
DIR_W=15

row_format() { # $1: window|pane
  local coord active
  if [ "$1" = pane ]; then
    coord='#{session_name}:#{window_index}.#{pane_index}'
    active='#{?#{&&:#{pane_active},#{window_active}},*, }'
  else
    coord='#{session_name}:#{window_index}'
    active='#{?window_active,*, }'
  fi
  printf '%s	%s	%s	%s%s	%s	%s' \
    "#{${1}_id}" '#{session_id}' '#{window_activity}' \
    "$active" "#{p${TARGET_W}:#{=/$((TARGET_W - 1))/…:${coord}}}" \
    "#{p${DIR_W}:#{=/$((DIR_W - 1))/…:#{b:pane_current_path}}}" \
    '#{?#{==:#{pane_title},#{host}},#{window_name},#{pane_title}}'
}

# 마지막 활동은 시각이 아니라 경과로 읽는다 — 목록에서 궁금한 것은 "몇 시였나"가
# 아니라 "얼마나 놀고 있나"다. tmux 의 t/p 는 시각만 주므로 여기서 환산한다.
with_age() {
  awk -F'\t' -v now="$(date +%s)" 'BEGIN { OFS = "\t" } {
    d = now - $3
    if (d < 60)         age = d "s"
    else if (d < 3600)  age = int(d / 60) "m"
    else if (d < 86400) age = int(d / 3600) "h"
    else                age = int(d / 86400) "d"
    printf "%s\t%s\t%s %s %4s  %s\n", $1, $2, $4, $5, age, $6
  }'
}

list_windows() { tmux list-windows -a -F "$(row_format window)" | with_age; }
list_panes()   { tmux list-panes   -a -F "$(row_format pane)"   | with_age; }

case "${1:-}" in
  --windows) list_windows; exit 0 ;;
  --panes)   list_panes;   exit 0 ;;
  --toggle)
    # tab 은 두 목록을 오간다. 현재 어느 목록인지는 prompt 가 기억한다.
    case "${FZF_PROMPT:-}" in
      window*) printf 'reload(%s --panes)+change-prompt(pane> )\n'     "$self" ;;
      *)       printf 'reload(%s --windows)+change-prompt(window> )\n' "$self" ;;
    esac
    exit 0 ;;
esac

command -v fzf >/dev/null || { echo "fzf not found" >&2; exit 1; }

# 앞 두 필드는 id(@n·%n·$n)라 세션·window 이름에 공백이 들어와도 안 깨진다.
# 사람이 보는 것은 3번째 필드뿐이고, id 는 --with-nth 로 감춘다.
line=$(
  list_windows |
  fzf --ansi \
      --delimiter='\t' \
      --with-nth=3 \
      --reverse \
      --prompt='window> ' \
      --header='enter: 전환   tab: window↔pane   ctrl-c: 취소' \
      --bind="tab:transform:$self --toggle" \
      --preview='tmux capture-pane -ep -t {1}' \
      --preview-window='right,60%,border-left'
) || exit 0

[ -n "$line" ] || exit 0

IFS=$'\t' read -r target session_id _ <<<"$line"

# window target 은 pane id 로도 풀린다 — pane 을 고르면 그 pane 의 window 로 간다.
tmux select-window -t "$target"
case "$target" in
  %*) tmux select-pane -t "$target" ;;
esac
tmux switch-client -t "$session_id"
