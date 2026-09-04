#!/bin/bash
# window 목록을 미리보기와 함께 고른다 — 미리보기는 오른쪽에 선다.
#
# tmux 내장 choose-tree(prefix + s)는 미리보기를 항상 목록 아래에 그린다
# (mode-tree.c 가 y 좌표를 `sy - h` 로 박아 놓았다). 위치를 바꾸는 옵션도 포맷도
# 없어서, 오른쪽 미리보기는 fzf 로 목록을 다시 짜는 수밖에 없다.
#
# display-popup -E 안에서 돌므로 popup 을 띄운 client 를 그대로 조작한다.
#
# 사용: tmux-window-picker.sh

set -u

command -v fzf >/dev/null || { echo "fzf not found" >&2; exit 1; }

# 앞 두 필드는 id(@n·$n)라 세션·window 이름에 공백이 들어와도 안 깨진다.
# 사람이 보는 것은 3번째 필드뿐이고, id 는 --with-nth 로 감춘다.
# 정렬은 tmux 포맷 padding 으로 낸다 — BSD column 에는 -o 가 없다.
line=$(
  tmux list-windows -a -F \
    '#{window_id}	#{session_id}	#{p10:#{session_name}:#{window_index}} #{window_name}#{?window_active, *,}' |
  fzf --ansi \
      --delimiter='\t' \
      --with-nth=3 \
      --reverse \
      --prompt='window> ' \
      --header='enter: 전환   ctrl-c: 취소' \
      --preview='tmux capture-pane -ep -t {1}' \
      --preview-window='right,60%,border-left'
) || exit 0

[ -n "$line" ] || exit 0

IFS=$'\t' read -r window_id session_id _ <<<"$line"

tmux select-window -t "$window_id"
tmux switch-client -t "$session_id"
