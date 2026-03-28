#!/usr/bin/env bash
set -euo pipefail

[[ -n "${TMUX_PANE:-}" ]] || exit 0

EVENT="${1:?usage: tmux-status.sh <event_name>}"

# Load emoji config
source "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/tmux-status-config.sh"

ALL_EMOJIS=(
  "$EMOJI_SESSION_START"
  "$EMOJI_USER_PROMPT_SUBMIT"
  "$EMOJI_PRE_TOOL_USE"
  "$EMOJI_POST_TOOL_USE"
  "$EMOJI_POST_TOOL_USE_FAILURE"
  "$EMOJI_PERMISSION_REQUEST"
  "$EMOJI_NOTIFICATION"
  "$EMOJI_STOP"
)

strip_emojis() {
  local text="$1"
  for e in "${ALL_EMOJIS[@]}"; do
    text="${text//$e/}"
  done
  # trim leading/trailing whitespace
  text="${text#"${text%%[![:space:]]*}"}"
  text="${text%"${text##*[![:space:]]}"}"
  echo "$text"
}

update_prefix() {
  local emoji="$1"
  local raw_name
  raw_name=$(tmux display-message -t "$TMUX_PANE" -p '#{window_name}')
  local name
  name=$(strip_emojis "$raw_name")
  tmux rename-window -t "$TMUX_PANE" "${emoji} ${name}"
}

remove_prefix() {
  local raw_name
  raw_name=$(tmux display-message -t "$TMUX_PANE" -p '#{window_name}')
  local name
  name=$(strip_emojis "$raw_name")
  tmux rename-window -t "$TMUX_PANE" "$name"
}

case "$EVENT" in
  SessionStart)
    tmux set-option -w -t "$TMUX_PANE" automatic-rename off
    update_prefix "$EMOJI_SESSION_START"
    ;;
  SessionEnd)
    remove_prefix
    tmux set-option -w -t "$TMUX_PANE" automatic-rename on
    ;;
  UserPromptSubmit) update_prefix "$EMOJI_USER_PROMPT_SUBMIT" ;;
  PreToolUse)         update_prefix "$EMOJI_PRE_TOOL_USE" ;;
  PostToolUse)        update_prefix "$EMOJI_POST_TOOL_USE" ;;
  PostToolUseFailure) update_prefix "$EMOJI_POST_TOOL_USE_FAILURE" ;;
  PermissionRequest)  update_prefix "$EMOJI_PERMISSION_REQUEST" ;;
  Notification)       update_prefix "$EMOJI_NOTIFICATION" ;;
  Stop)               update_prefix "$EMOJI_STOP" ;;
esac
