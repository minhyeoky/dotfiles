#!/usr/bin/env bash
# Shared helpers for tmux-status.sh. Source-only.

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
