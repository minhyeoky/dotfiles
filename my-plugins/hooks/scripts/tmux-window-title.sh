#!/usr/bin/env bash
# Name the Claude Code session after its tmux window — SessionStart &
# UserPromptSubmit hook. With several sessions in one window, the second and
# later (in pane order) get a suffix: "main", "main·2", "main·3".
#
# The window name is read fresh on every prompt, so renaming the window by any
# means (prefix + ',', tmux-oil, rename-window) reaches the session on its next
# prompt. Nothing pushes into an idle session: the only way in from outside is
# send-keys, which would type into whatever the person is writing.
#
# Only UserPromptSubmit sets the title. A title set at SessionStart reaches the
# session's own UI but not the name peers see (the session registry), and the
# first prompt's identical title then changes nothing, so the registry would
# keep the derived name. SessionStart only drops the cache instead: startup,
# resume and clear can each bring a different title into the pane.
#
# The last title set is cached on the pane (@cc_title), and a title is emitted
# only when the computed one differs. A manual /rename therefore holds until the
# window name or pane order changes.
set -uo pipefail

[[ -n "${TMUX:-}" ]] || exit 0

EVENT="${1:?usage: tmux-window-title.sh <event_name>}"

# Echo the pane whose own top-level session runs this hook; empty otherwise.
#
# Like tmux-status, the pane is found by walking our ancestry to a pane_pid
# rather than trusting $TMUX_PANE. On top of that, the nearest claude ancestor
# must be the pane's process or its direct child: a session spawned by a script
# or another session inside the pane has its own name and must keep it.
owned_pane() {
  tmux list-panes -a -F '#{pane_pid} #{pane_id}' 2>/dev/null | awk -v start=$$ '
    { owner[$1] = $2; panes++ }
    END {
      if (!panes) exit
      while (("ps -Ao pid=,ppid=,comm=" | getline) > 0) {
        parent[$1] = $2
        n = split($3, part, "/")
        isclaude[$1] = (part[n] ~ /^claude/)
      }
      p = start; claude = ""
      for (i = 0; i < 64 && p != "" && p != "0" && p != "1"; i++) {
        if (claude == "" && isclaude[p]) claude = p
        if (p in owner) {
          if (claude != "" && (claude == p || parent[claude] == p)) printf "%s", owner[p]
          exit
        }
        p = parent[p]
      }
    }'
}

PANE=$(owned_pane)
[[ -n "$PANE" ]] || exit 0

if [[ "$EVENT" == SessionStart ]]; then
  tmux set-option -p -u -t "$PANE" @cc_title 2>/dev/null || true
  exit 0
fi

IFS=$'\t' read -r WIN NAME AUTO < <(tmux display-message -p -t "$PANE" \
  '#{window_id}	#{window_name}	#{automatic-rename}' 2>/dev/null) || exit 0
# An automatically named window carries the command name, not a chosen one.
[[ -n "$NAME" && "$AUTO" != 1 ]] || exit 0

RANK=$(tmux list-panes -t "$WIN" -F '#{pane_id} #{pane_current_command}' 2>/dev/null |
  awk -v me="$PANE" '$2 ~ /^claude/ { n++ } $1 == me { print n; exit }')
TITLE=$NAME
[[ -n "$RANK" && "$RANK" -gt 1 ]] && TITLE="${NAME}·${RANK}"

[[ "$(tmux show-options -pqv -t "$PANE" @cc_title 2>/dev/null)" == "$TITLE" ]] && exit 0
tmux set-option -p -t "$PANE" @cc_title "$TITLE" 2>/dev/null || true

ESC=$(printf '%s' "$TITLE" | sed 's/\\/\\\\/g; s/"/\\"/g')
printf '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","sessionTitle":"%s"}}\n' "$ESC"
