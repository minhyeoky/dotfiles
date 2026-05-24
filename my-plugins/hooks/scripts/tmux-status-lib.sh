#!/usr/bin/env bash
# Shared helpers for tmux-status.sh. Source-only.

# Truncate to TMUX_STATUS_TITLE_MAXLEN chars (default 50), append … if cut.
# Uses python3 because bash 3.2 (macOS default) counts bytes in ${s:0:N},
# which would mangle Korean/CJK mid-codepoint.
truncate_title() {
  local s="${1:-}" m="${TMUX_STATUS_TITLE_MAXLEN:-50}"
  [[ -z "$s" ]] && return
  python3 -c 'import sys
s, m = sys.argv[1], int(sys.argv[2])
sys.stdout.write(s if len(s) <= m else s[:m] + "…")' "$s" "$m" 2>/dev/null || printf '%s' "$s"
}
