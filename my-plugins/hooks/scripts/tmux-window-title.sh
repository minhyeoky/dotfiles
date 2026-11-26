#!/usr/bin/env bash
# Name the Claude Code session after its tmux window — SessionStart &
# UserPromptSubmit hook. With several sessions in one window, the second and
# later (in pane order) get a suffix: "main", "main·2", "main·3".
#
# The window name is read fresh on every prompt, so renaming the window by any
# means (prefix + ',', tmux-oil, rename-window) reaches the session on its next
# prompt. Nothing pushes into an idle session: the only way in from outside is
# send-keys, which would type into whatever is being typed.
#
# Only UserPromptSubmit sets the title. A title set at SessionStart reaches the
# session's own UI but not the name peers see (the session registry), and the
# first prompt's identical title then changes nothing, so the registry would
# keep the name Claude Code generated. SessionStart only drops the cache
# instead: startup, resume and clear can each bring a different title into the
# pane. Compact keeps the session and its title, so it keeps the cache too.
#
# The last title set is cached on the pane (@cc_title), and a title is emitted
# only when the computed one differs. A manual /rename therefore holds until the
# window name or pane order changes.
set -uo pipefail

[[ -n "${TMUX:-}" ]] || exit 0

EVENT="${1:?usage: tmux-window-title.sh <event_name>}"

# Echo "<pane_id> <rank>" for the pane whose own session runs this hook, where
# rank is that pane's place among the window's Claude panes; empty otherwise.
#
# Like tmux-status, the pane is found by walking our ancestry to a pane_pid
# rather than trusting $TMUX_PANE, which child processes inherit. On top of
# that, the nearest claude ancestor must be the pane's process or its direct
# child: a session spawned by a script or another session inside the pane has
# its own name and must keep it. Other panes are ranked by the same test, read
# from the same process table, so a pane whose foreground briefly runs an
# editor still counts and a pane running a nested session does not.
#
# The pane list arrives on stdin and the process table through getline: awk -v
# cannot carry either, since it rejects a newline inside an assigned value.
owned_pane() {
  tmux list-panes -a -F '#{pane_pid} #{pane_id} #{window_id}' 2>/dev/null | awk -v start=$$ '
    !seen[$2]++ { order[++panes] = $2; pid[$2] = $1; win[$2] = $3; owner[$1] = $2 }
    END {
      if (!panes) exit
      while (("ps -Ao pid=,ppid=,comm=" | getline) > 0) {
        parent[$1] = $2
        n = split($3, part, "/")
        if (part[n] ~ /^claude/) { isclaude[$1] = 1; claudechild[$2] = 1 }
      }
      p = start; claude = ""; me = ""
      # The hop cap guards against a malformed table, not a real ancestry depth.
      for (i = 0; i < 64 && p != "" && p != "0" && p != "1"; i++) {
        if (claude == "" && (p in isclaude)) claude = p
        if (p in owner) {
          if (claude != "" && (claude == p || parent[claude] == p)) me = owner[p]
          break
        }
        p = parent[p]
      }
      if (me == "") exit
      for (k = 1; k <= panes; k++) {
        id = order[k]
        if (win[id] != win[me]) continue
        if ((pid[id] in isclaude) || (pid[id] in claudechild)) rank++
        if (id == me) { printf "%s %d", me, rank; exit }
      }
    }'
}

read -r PANE RANK < <(owned_pane)
[[ -n "${PANE:-}" ]] || exit 0

if [[ "$EVENT" == SessionStart ]]; then
  grep -qE '"source"[[:space:]]*:[[:space:]]*"compact"' && exit 0
  tmux set-option -p -u -t "$PANE" @cc_title 2>/dev/null || true
  exit 0
fi

# A unit separator, not a tab: tabs are IFS whitespace, so an empty window name
# would collapse into its neighbour and shift the fields.
US=$'\x1f'
IFS=$US read -r NAME AUTO < <(tmux display-message -p -t "$PANE" \
  "#{window_name}${US}#{automatic-rename}" 2>/dev/null) || exit 0
# An automatically named window carries the command name, not a chosen one.
[[ -n "$NAME" && "$AUTO" != 1 ]] || exit 0

TITLE=$NAME
[[ "${RANK:-0}" -gt 1 ]] && TITLE="${NAME}·${RANK}"

[[ "$(tmux show-options -pqv -t "$PANE" @cc_title 2>/dev/null)" == "$TITLE" ]] && exit 0
tmux set-option -p -t "$PANE" @cc_title "$TITLE" 2>/dev/null || true

ESC=$(printf '%s' "$TITLE" | sed 's/\\/\\\\/g; s/"/\\"/g')
printf '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","sessionTitle":"%s"}}\n' "$ESC"
