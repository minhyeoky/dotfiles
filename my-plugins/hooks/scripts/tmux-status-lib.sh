#!/usr/bin/env bash
# Shared helpers for tmux-status.sh. Source-only.

# Truncate to TMUX_STATUS_TITLE_MAXLEN chars (default 50), append … if cut.
# Uses python3 because bash 3.2 (macOS default) counts bytes in ${s:0:N},
# which would mangle Korean/CJK mid-codepoint.
truncate_title() {
  local s="${1:-}" m="${TMUX_STATUS_TITLE_MAXLEN:-50}"
  [[ -z "$s" ]] && return
  python3 -c 'import sys
s, m = sys.argv[1], int(sys.argv[2])
sys.stdout.write(s if len(s) <= m else s[:m] + "…")' "$s" "$m" 2>/dev/null || printf '%s' "$s"
}

# Echo the pane this process actually runs in.
#
# $TMUX_PANE is inherited by child processes, so a Claude Code session started by
# another pane's process reads its parent's pane id and would stamp state onto the
# wrong pane. Walking our own ancestry until a pid matches some pane's pane_pid is
# exact: the match is the pane that owns this process tree.
resolve_pane() {
  local p=$$ found
  while [[ -n "$p" && "$p" != "1" ]]; do
    found=$(tmux list-panes -a -F '#{pane_pid} #{pane_id}' 2>/dev/null |
      awk -v x="$p" '$1==x{print $2}')
    [[ -n "$found" ]] && { printf '%s' "$found"; return 0; }
    p=$(ps -o ppid= -p "$p" 2>/dev/null | tr -d ' ')
  done
  printf '%s' "${TMUX_PANE:-}"
}

# Echo the most attention-worthy @cc_state among the panes sharing a window.
#
# A window name is per-window, but a window can hold several sessions. Renaming
# from whichever pane fired last then yields an emoji that belongs to no
# identifiable session; picking by a fixed priority makes it deterministic.
aggregate_emoji() {
  local pane="${1:-}" states e
  states=" $(tmux list-panes -t "$pane" -F '#{@cc_state}' 2>/dev/null | tr '\n' ' ')"
  for e in ${TMUX_STATUS_PRIORITY:-}; do
    [[ "$states" == *" $e "* ]] && { printf '%s' "$e"; return 0; }
  done
  # State outside the priority list (list out of date): show it rather than nothing.
  printf '%s' "$(printf '%s' "$states" | tr ' ' '\n' | grep -m1 . || true)"
}
