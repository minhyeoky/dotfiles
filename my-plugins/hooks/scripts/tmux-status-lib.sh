#!/usr/bin/env bash
# Shared helpers for tmux-status.sh. Source-only.

# A pane whose foreground command is a shell is not running a session, so any
# @cc_state on it outlived the process that wrote it — Claude Code only clears
# state on a clean SessionEnd, and a crash never gets there. Tool calls do not
# take the terminal foreground, so a live session always reports its own binary.
# The pane border applies the same rule as a tmux format (see @cc_live in tmux.conf).
_SHELL_RE='sh$'

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

# Echo one chip summarising every live session in the window holding $1, e.g.
# "🔓2🧠✅" — states ordered by TMUX_STATUS_PRIORITY, a count appended only where
# more than one pane sits in that state.
#
# A window name is a single slot but a window can hold several sessions, so the
# tab list needs the whole set, not whichever pane fired last. Renaming the
# window would also mean turning automatic-rename off; writing @cc_win instead
# leaves tmux's own name intact and lets window-status-format compose the two.
aggregate_states() {
  local pane="${1:-}"
  [[ -n "$pane" ]] || return 0
  tmux list-panes -t "$pane" -F '#{pane_current_command} #{@cc_state}' 2>/dev/null |
    awk -v prio="${TMUX_STATUS_PRIORITY:-}" -v shell_re="$_SHELL_RE" '
      $2 != "" && $1 !~ shell_re { seen[$2]++ }
      END {
        n = split(prio, order, " ")
        for (i = 1; i <= n; i++) if (order[i] in seen) {
          printf "%s%s", order[i], (seen[order[i]] > 1 ? seen[order[i]] : "")
          delete seen[order[i]]
        }
        # A state missing from the priority list means the list is out of date;
        # show it rather than swallowing it.
        for (s in seen) printf "%s%s", s, (seen[s] > 1 ? seen[s] : "")
      }'
}
