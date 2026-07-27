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
#
# The window name is left to tmux. Only two states actually need attention from
# another window — waiting on permission and waiting on input — and Claude Code
# already rings the terminal bell for both, which reddens the window in the tab
# list on its own.
mark() {
  tmux set-option -p -t "$PANE" @cc_state "${1:-}" 2>/dev/null || true
}

case "$EVENT" in
  SessionStart)       mark "$EMOJI_SESSION_START" ;;
  SessionEnd)         tmux set-option -pu -t "$PANE" @cc_state 2>/dev/null || true ;;
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
