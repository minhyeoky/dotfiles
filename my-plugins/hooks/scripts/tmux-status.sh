#!/usr/bin/env bash
set -uo pipefail

[[ -n "${TMUX:-}${TMUX_PANE:-}" ]] || exit 0

EVENT="${1:?usage: tmux-status.sh <event_name>}"

source "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/tmux-status-config.sh"
source "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/tmux-status-lib.sh"

PANE=$(resolve_pane)
[[ -n "$PANE" ]] || exit 0

# The pane owns its own state, because a window can hold several sessions and a
# per-session signal survives nowhere else. A pane option is also the only thing
# that survives tmux moving the pane: swap-pane, break-pane and join-pane all
# carry pane_id and its options along, so maximize (prefix + +, which is
# new-window + swap-pane, not zoom) never separates a session from its state.
#
# This writes nothing at the window level. The tab list needs the window's whole
# set, but a stored aggregate has two inputs — session state, which we see, and
# window/pane membership, which only tmux sees and never announces. So the tab
# chip is derived at render time instead, by @cc_chip in tmux.conf looping the
# window's panes. A value that is never stored cannot go stale.
mark() {
  tmux set-option -p -t "$PANE" @cc_state "${1:-}" 2>/dev/null || true
}

# Park the session id on the pane so a person can lift it without a transcript
# hunt — it is a UUID, and unlike the pane id on the border it cannot be retyped
# from sight. Only SessionStart reads stdin: startup, resume, clear, compact and
# fork all raise it, so every id change is covered at one grep per session rather
# than one per tool call.
stamp_session_id() {
  local sid
  sid=$(grep -oE '"session_id"[[:space:]]*:[[:space:]]*"[^"]+"' | head -1 |
    sed 's/.*"\(.*\)"$/\1/')
  [[ -n "$sid" ]] || return 0
  tmux set-option -p -t "$PANE" @cc_sid "$sid" 2>/dev/null || true
}

case "$EVENT" in
  SessionStart)
    stamp_session_id
    mark "$EMOJI_SESSION_START"
    ;;
  SessionEnd)
    tmux set-option -pu -t "$PANE" @cc_state 2>/dev/null || true
    tmux set-option -pu -t "$PANE" @cc_sid 2>/dev/null || true
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
