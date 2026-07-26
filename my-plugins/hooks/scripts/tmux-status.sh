#!/usr/bin/env bash
set -uo pipefail

[[ -n "${TMUX:-}${TMUX_PANE:-}" ]] || exit 0

EVENT="${1:?usage: tmux-status.sh <event_name>}"

source "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/tmux-status-config.sh"
source "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/tmux-status-lib.sh"

PANE=$(resolve_pane)
[[ -n "$PANE" ]] || exit 0

# The pane owns its own state. A window can hold several sessions, so this is the
# only place a per-session signal survives; the pane border renders @cc_state.
mark() {
  tmux set-option -p -t "$PANE" @cc_state "${1:-}" 2>/dev/null || true
  rename
}

# The window name carries the window's most attention-worthy state plus the active
# pane's title, so it stays meaningful in the tab list — where the pane borders of
# other windows are not drawn — without any pane clobbering another's status.
rename() {
  local win emoji title name
  win=$(tmux display-message -t "$PANE" -p '#{window_id}' 2>/dev/null) || return
  emoji=$(aggregate_emoji "$PANE")
  # Claude Code writes a semantic summary of the conversation into pane_title via
  # OSC escape sequences; prefer that over cwd basename for window naming. Fall
  # back to folder only when pane_title is empty (e.g., before CC has set it).
  title=$(tmux display-message -t "$win" -p '#{pane_title}' 2>/dev/null) || title=""
  if [[ -z "$title" ]]; then
    title=$(tmux display-message -t "$win" -p '#{b:pane_current_path}' 2>/dev/null) || title=""
  fi
  title=$(truncate_title "$title")
  name="${emoji:+$emoji }${title}"
  tmux rename-window -t "$win" "$name" 2>/dev/null || true
}

case "$EVENT" in
  SessionStart)
    tmux set-option -w -t "$PANE" automatic-rename off 2>/dev/null || true
    mark "$EMOJI_SESSION_START"
    ;;
  SessionEnd)
    tmux set-option -pu -t "$PANE" @cc_state 2>/dev/null || true
    # Only hand the name back to tmux once no session is left in the window;
    # otherwise the departing pane would erase a sibling session's status.
    if [[ -z "$(aggregate_emoji "$PANE")" ]]; then
      tmux set-option -w -t "$PANE" automatic-rename on 2>/dev/null || true
    else
      rename
    fi
    ;;
  UserPromptSubmit)   mark "$EMOJI_USER_PROMPT_SUBMIT" ;;
  PreToolUse)         mark "$EMOJI_PRE_TOOL_USE" ;;
  PostToolUse)        mark "$EMOJI_POST_TOOL_USE" ;;
  PostToolUseFailure) mark "$EMOJI_POST_TOOL_USE_FAILURE" ;;
  PermissionRequest)  mark "$EMOJI_PERMISSION_REQUEST" ;;
  Notification)       mark "$EMOJI_NOTIFICATION" ;;
  Stop)               mark "$EMOJI_STOP" ;;
  # compact 진행 동안 직전 emoji에 멈추지 않도록 압축 상태를 표시한다.
  # compact 종료 후엔 SessionStart(source=compact)가 다시 발생해 복원한다.
  PreCompact)         mark "$EMOJI_PRE_COMPACT" ;;
esac
