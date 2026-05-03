#!/usr/bin/env bash
# Periodically refresh the tmux window title with elapsed time + delta tokens
# since the last UserPromptSubmit. Spawned by tmux-status.sh on UserPromptSubmit.
#
# Self-exits on any of:
#   - state file gone (SessionEnd / new session reset)
#   - Claude process gone (zombie prevention via `kill -0 $claude_pid`)
#   - tmux pane gone
#   - SIGTERM from a fresh hook invocation killing the previous daemon
set -uo pipefail

SESSION_ID="${1:?usage: tmux-status-daemon.sh <session_id>}"

source "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/tmux-status-config.sh"
source "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/tmux-status-lib.sh"

STATE_DIR="${TMPDIR:-/tmp}"
STATE_DIR="${STATE_DIR%/}/cc-tmux-status"
STATE_FILE="${STATE_DIR}/${SESSION_ID}.state"

get_state() {
  grep "^${1}=" "$STATE_FILE" 2>/dev/null | head -1 | cut -d= -f2-
}

last_mtime=""
last_in=0
last_out=0

while sleep 1; do
  [[ -r "$STATE_FILE" ]] || exit 0

  active_seconds=$(get_state active_seconds)
  tick_start_epoch=$(get_state tick_start_epoch)
  baseline_input=$(get_state baseline_input)
  baseline_output=$(get_state baseline_output)
  transcript_path=$(get_state transcript_path)
  pane=$(get_state pane)
  claude_pid=$(get_state claude_pid)
  current_emoji=$(get_state current_emoji)

  [[ "$active_seconds"  =~ ^[0-9]+$ ]] || exit 0
  [[ "$baseline_input"  =~ ^[0-9]+$ ]] || exit 0
  [[ "$baseline_output" =~ ^[0-9]+$ ]] || exit 0
  [[ -n "$pane" ]] || exit 0

  # Zombie prevention: if Claude is gone, we go too.
  if [[ "$claude_pid" =~ ^[0-9]+$ ]]; then
    kill -0 "$claude_pid" 2>/dev/null || exit 0
  fi

  # Pane gone → exit.
  dir=$(tmux display-message -t "$pane" -p '#{b:pane_current_path}' 2>/dev/null) || exit 0

  # Recompute tokens only when transcript file actually changed.
  if [[ -n "$transcript_path" && -r "$transcript_path" ]]; then
    mtime=$(stat -f %m "$transcript_path" 2>/dev/null || stat -c %Y "$transcript_path" 2>/dev/null || echo "")
    if [[ -n "$mtime" && "$mtime" != "$last_mtime" ]]; then
      read -r new_in new_out <<<"$(compute_tokens "$transcript_path")"
      last_in=${new_in:-$last_in}
      last_out=${new_out:-$last_out}
      last_mtime=$mtime
    fi
  fi

  elapsed=$(compute_elapsed "$active_seconds" "$tick_start_epoch")
  delta_in=$((last_in - baseline_input))
  delta_out=$((last_out - baseline_output))
  (( delta_in < 0 )) && delta_in=0
  (( delta_out < 0 )) && delta_out=0

  metrics="$(format_elapsed "$elapsed") ↑$(format_tokens "$delta_in") ↓$(format_tokens "$delta_out")"
  tmux rename-window -t "$pane" "${current_emoji:+$current_emoji }${metrics} ${dir}" 2>/dev/null || true
done
