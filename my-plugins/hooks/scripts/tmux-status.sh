#!/usr/bin/env bash
set -euo pipefail

[[ -n "${TMUX_PANE:-}" ]] || exit 0

EVENT="${1:?usage: tmux-status.sh <event_name>}"

source "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/tmux-status-config.sh"

rename() {
  local dir
  dir=$(tmux display-message -t "$TMUX_PANE" -p '#{b:pane_current_path}')
  tmux rename-window -t "$TMUX_PANE" "${1:+$1 }${dir}"
}

case "$EVENT" in
  SessionStart)
    tmux set-option -w -t "$TMUX_PANE" automatic-rename off
    rename "$EMOJI_SESSION_START"
    ;;
  SessionEnd)
    tmux set-option -w -t "$TMUX_PANE" automatic-rename on
    ;;
  UserPromptSubmit) rename "$EMOJI_USER_PROMPT_SUBMIT" ;;
  PreToolUse)         rename "$EMOJI_PRE_TOOL_USE" ;;
  PostToolUse)        rename "$EMOJI_POST_TOOL_USE" ;;
  PostToolUseFailure) rename "$EMOJI_POST_TOOL_USE_FAILURE" ;;
  PermissionRequest)  rename "$EMOJI_PERMISSION_REQUEST" ;;
  Notification)       rename "$EMOJI_NOTIFICATION" ;;
  Stop)               rename "$EMOJI_STOP" ;;
esac
