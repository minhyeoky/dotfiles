#!/usr/bin/env bash
set -euo pipefail

[[ -n "${TMUX_PANE:-}" ]] || exit 0

EVENT="${1:?usage: tmux-status.sh <event_name>}"

# Load emoji config
source "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/tmux-status-config.sh"

ALL_EMOJIS=()
for var in "${!EMOJI_@}"; do
  ALL_EMOJIS+=("${!var}")
done

strip_prefix() {
  local text="$1"
  for e in "${ALL_EMOJIS[@]}"; do
    if [[ "$text" == "${e} "* ]]; then
      text="${text#"${e} "}"
      break
    fi
  done
  echo "$text"
}

set_window_name() {
  local prefix="${1:-}"
  local raw_name
  raw_name=$(tmux display-message -t "$TMUX_PANE" -p '#{window_name}')
  local name
  name=$(strip_prefix "$raw_name")
  local new_name="${prefix:+$prefix }${name}"
  [[ "$raw_name" == "$new_name" ]] && return 0
  tmux rename-window -t "$TMUX_PANE" "$new_name"
}

case "$EVENT" in
  SessionStart)
    tmux set-option -w -t "$TMUX_PANE" automatic-rename off
    set_window_name "$EMOJI_SESSION_START"
    ;;
  SessionEnd)
    set_window_name
    tmux set-option -w -t "$TMUX_PANE" automatic-rename on
    ;;
  UserPromptSubmit) set_window_name "$EMOJI_USER_PROMPT_SUBMIT" ;;
  PreToolUse)         set_window_name "$EMOJI_PRE_TOOL_USE" ;;
  PostToolUse)        set_window_name "$EMOJI_POST_TOOL_USE" ;;
  PostToolUseFailure) set_window_name "$EMOJI_POST_TOOL_USE_FAILURE" ;;
  PermissionRequest)  set_window_name "$EMOJI_PERMISSION_REQUEST" ;;
  Notification)       set_window_name "$EMOJI_NOTIFICATION" ;;
  Stop)               set_window_name "$EMOJI_STOP" ;;
esac
