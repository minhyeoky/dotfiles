#!/bin/bash
# 현재 window 의 pane 을 목표 개수까지 채우고 균등 세로분할로 맞춘다.
#
# pane 폭은 화면 폭을 개수로 나눈 값이라, 개수를 고정해야 폭이 고정된다.
# 목표를 이미 넘었으면 아무것도 하지 않는다 — pane 을 죽이지 않는다.
#
# 사용: tmux-even-fill.sh [개수]   (기본 4)

set -u
target="${1:-4}"

case "$target" in
  ''|*[!0-9]*) echo "usage: $(basename "$0") [pane count]" >&2; exit 2 ;;
esac
[ "$target" -ge 1 ] || { echo "pane count must be >= 1" >&2; exit 2; }

panes=$(tmux display-message -p '#{window_panes}')

# split 은 남은 폭이 모자라면 실패한다. 그때는 거기서 멈추고
# 만들어진 만큼으로 레이아웃을 잡는다.
while [ "$panes" -lt "$target" ]; do
  tmux split-window -h -c '#{pane_current_path}' || break
  panes=$((panes + 1))
done

tmux select-layout even-horizontal >/dev/null
