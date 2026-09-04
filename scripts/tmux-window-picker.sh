#!/bin/bash
# window·pane 목록을 미리보기와 함께 고른다 — 미리보기는 오른쪽에 선다.
#
# tmux 내장 choose-tree(prefix + s)는 미리보기를 항상 목록 아래에 그린다
# (mode-tree.c 가 y 좌표를 `sy - h` 로 박아 놓았고 위치를 바꾸는 옵션도 포맷도
# 없다). 오른쪽 미리보기가 필요해서 목록을 fzf 로 다시 짰다.
#
# display-popup -E 안에서 돌므로 popup 을 띄운 client 를 그대로 조작한다.
# client 가 여럿 붙어 있으면 switch-client 대상은 tmux 가 고른 현재 client 다.
#
# 사용: tmux-window-picker.sh
#   내부 호출: --windows | --panes (fzf reload 용) · --toggle (tab 키 액션)

set -u

# fzf 가 reload·transform 으로 이 스크립트를 다시 부르므로 경로가 절대여야 한다.
self=$(cd -- "$(dirname -- "$0")" && pwd)/$(basename -- "$0")

# 앞 두 필드는 id(@n·%n·$n)라 세션·window 이름에 공백이 들어와도 안 깨진다.
# 사람이 보는 것은 3번째 필드뿐이고, id 는 --with-nth 로 감춘다.
# 정렬은 tmux 포맷 padding 으로 낸다 — BSD column 에는 -o 가 없다.
list_windows() {
  tmux list-windows -a -F \
    '#{window_id}	#{session_id}	#{p12:#{session_name}:#{window_index}} #{window_name}#{?window_active, *,}'
}

list_panes() {
  tmux list-panes -a -F \
    '#{pane_id}	#{session_id}	#{p12:#{session_name}:#{window_index}.#{pane_index}} #{window_name}  #{pane_current_command}#{?pane_active, *,}'
}

case "${1:-}" in
  --windows) list_windows; exit 0 ;;
  --panes)   list_panes;   exit 0 ;;
  --toggle)
    # tab 은 두 목록을 오간다. 현재 어느 목록인지는 prompt 가 기억한다.
    case "${FZF_PROMPT:-}" in
      window*) printf 'reload(%s --panes)+change-prompt(pane> )\n'   "$self" ;;
      *)       printf 'reload(%s --windows)+change-prompt(window> )\n' "$self" ;;
    esac
    exit 0 ;;
esac

command -v fzf >/dev/null || { echo "fzf not found" >&2; exit 1; }

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
