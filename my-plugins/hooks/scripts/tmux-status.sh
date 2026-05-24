#!/usr/bin/env bash
set -uo pipefail

[[ -n "${TMUX_PANE:-}" ]] || exit 0

EVENT="${1:?usage: tmux-status.sh <event_name>}"

source "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/tmux-status-config.sh"
source "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/tmux-status-lib.sh"

rename() {
  local emoji="${1:-}" pane_title name
  # Claude Code writes a semantic summary of the conversation into pane_title via
  # OSC escape sequences; prefer that over cwd basename for window naming. Fall
  # back to folder only when pane_title is empty (e.g., before CC has set it).
  pane_title=$(tmux display-message -t "$TMUX_PANE" -p '#{pane_title}' 2>/dev/null) || pane_title=""
  if [[ -z "$pane_title" ]]; then
    pane_title=$(tmux display-message -t "$TMUX_PANE" -p '#{b:pane_current_path}' 2>/dev/null) || pane_title=""
  fi
  pane_title=$(truncate_title "$pane_title")
  name="${emoji:+$emoji }${pane_title}"
  tmux rename-window -t "$TMUX_PANE" "$name" 2>/dev/null || true
}

case "$EVENT" in
  SessionStart)
    tmux set-option -w -t "$TMUX_PANE" automatic-rename off 2>/dev/null || true
    rename "$EMOJI_SESSION_START"
    ;;
  SessionEnd)
    tmux set-option -w -t "$TMUX_PANE" automatic-rename on 2>/dev/null || true
    ;;
  UserPromptSubmit)   rename "$EMOJI_USER_PROMPT_SUBMIT" ;;
  PreToolUse)         rename "$EMOJI_PRE_TOOL_USE" ;;
  PostToolUse)        rename "$EMOJI_POST_TOOL_USE" ;;
  PostToolUseFailure) rename "$EMOJI_POST_TOOL_USE_FAILURE" ;;
  PermissionRequest)  rename "$EMOJI_PERMISSION_REQUEST" ;;
  Notification)       rename "$EMOJI_NOTIFICATION" ;;
  Stop)               rename "$EMOJI_STOP" ;;
esac
