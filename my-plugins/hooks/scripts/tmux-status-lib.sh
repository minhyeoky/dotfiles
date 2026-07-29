#!/usr/bin/env bash
# Shared helpers for tmux-status.sh. Source-only.

# Echo the pane this process actually runs in; empty when it cannot be resolved.
#
# $TMUX_PANE is inherited by child processes, so a Claude Code session started by
# another pane's process reads its parent's pane id. Walking our own ancestry
# until a pid matches some pane's pane_pid is exact: the match is the pane that
# owns this process tree. There is deliberately no fallback to $TMUX_PANE — that
# is the very value the walk exists to distrust, and stamping state onto some
# other pane is worse than stamping none.
#
# One `tmux list-panes` and one `ps` for the whole walk: these hooks fire on every
# tool call, and a fork per ancestor adds up.
resolve_pane() {
  # The pane list arrives on stdin and the process table through getline: awk -v
  # cannot carry either, since it rejects a newline inside an assigned value.
  tmux list-panes -a -F '#{pane_pid} #{pane_id}' 2>/dev/null | awk -v start=$$ '
    { owner[$1] = $2; panes++ }
    END {
      if (!panes) exit
      while (("ps -Ao pid=,ppid=" | getline) > 0) parent[$1] = $2
      p = start
      # The hop cap guards against a malformed table, not a real ancestry depth.
      for (i = 0; i < 64 && p != "" && p != "0" && p != "1"; i++) {
        if (p in owner) { printf "%s", owner[p]; exit }
        p = parent[p]
      }
    }'
}
