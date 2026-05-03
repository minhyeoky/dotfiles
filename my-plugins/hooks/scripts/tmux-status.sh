#!/usr/bin/env bash
set -uo pipefail

[[ -n "${TMUX_PANE:-}" ]] || exit 0

EVENT="${1:?usage: tmux-status.sh <event_name>}"

source "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/tmux-status-config.sh"
source "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/tmux-status-lib.sh"

STDIN_JSON=""
[[ ! -t 0 ]] && STDIN_JSON=$(cat 2>/dev/null || true)

SESSION_ID=""
TRANSCRIPT_PATH=""
if [[ -n "$STDIN_JSON" ]]; then
  parsed=$(printf '%s' "$STDIN_JSON" \
    | jq -r '[.session_id // "", .transcript_path // ""] | @tsv' 2>/dev/null || true)
  IFS=$'\t' read -r SESSION_ID TRANSCRIPT_PATH <<<"$parsed"
fi

STATE_DIR="${TMPDIR:-/tmp}"
STATE_DIR="${STATE_DIR%/}/cc-tmux-status"

state_file() { [[ -n "$SESSION_ID" ]] || return 1; printf '%s/%s.state' "$STATE_DIR" "$SESSION_ID"; }
pid_file()   { [[ -n "$SESSION_ID" ]] || return 1; printf '%s/%s.pid'   "$STATE_DIR" "$SESSION_ID"; }

get_state() {
  local f
  f=$(state_file) || return 1
  grep "^${1}=" "$f" 2>/dev/null | head -1 | cut -d= -f2-
}

# In-place single-key update via temp-file rewrite (avoids macOS sed -i quirks).
set_state() {
  local key=$1 val=$2 f tmp
  f=$(state_file) || return 0
  [[ -r "$f" ]] || return 0
  tmp="${f}.tmp.$$"
  awk -v k="$key" -v v="$val" -F= '
    BEGIN { found=0 }
    $1 == k { print k "=" v; found=1; next }
    { print }
    END { if (!found) print k "=" v }
  ' "$f" >"$tmp" 2>/dev/null && mv "$tmp" "$f" 2>/dev/null || rm -f "$tmp" 2>/dev/null
}

write_initial_state() {
  local f
  f=$(state_file) || return 0
  mkdir -p "$STATE_DIR" 2>/dev/null || return 0
  local cur_in cur_out claude_pid
  read -r cur_in cur_out <<<"$(compute_tokens "$TRANSCRIPT_PATH")"
  cur_in=${cur_in:-0}; cur_out=${cur_out:-0}
  claude_pid=$(find_claude_pid || true)
  cat >"$f" <<EOF
start_epoch=$(date +%s)
baseline_input=${cur_in}
baseline_output=${cur_out}
transcript_path=${TRANSCRIPT_PATH}
pane=${TMUX_PANE}
claude_pid=${claude_pid}
current_emoji=${EMOJI_USER_PROMPT_SUBMIT}
EOF
}

clear_state() {
  local f p
  f=$(state_file 2>/dev/null) && rm -f "$f"
  p=$(pid_file   2>/dev/null) && rm -f "$p"
}

kill_daemon() {
  local p old
  p=$(pid_file 2>/dev/null) || return 0
  [[ -r "$p" ]] || return 0
  old=$(cat "$p" 2>/dev/null)
  [[ "$old" =~ ^[0-9]+$ ]] && kill "$old" 2>/dev/null || true
  rm -f "$p"
}

spawn_daemon() {
  [[ "${TMUX_STATUS_SHOW_METRICS:-1}" == "1" ]] || return 0
  [[ -n "$SESSION_ID" ]] || return 0
  local p
  p=$(pid_file) || return 0
  nohup env CLAUDE_PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT}" TMPDIR="${TMPDIR:-/tmp}" \
    "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/tmux-status-daemon.sh" "$SESSION_ID" \
    </dev/null >/dev/null 2>&1 &
  echo $! >"$p"
  disown 2>/dev/null || true
}

build_metrics_suffix() {
  [[ "${TMUX_STATUS_SHOW_METRICS:-1}" == "1" ]] || return 0
  local start_epoch baseline_input baseline_output
  start_epoch=$(get_state start_epoch)
  baseline_input=$(get_state baseline_input)
  baseline_output=$(get_state baseline_output)
  [[ "$start_epoch"     =~ ^[0-9]+$ ]] || return 0
  [[ "$baseline_input"  =~ ^[0-9]+$ ]] || return 0
  [[ "$baseline_output" =~ ^[0-9]+$ ]] || return 0
  local now elapsed cur_in cur_out
  now=$(date +%s)
  elapsed=$((now - start_epoch))
  (( elapsed < 0 )) && elapsed=0
  read -r cur_in cur_out <<<"$(compute_tokens "$TRANSCRIPT_PATH")"
  cur_in=${cur_in:-0}; cur_out=${cur_out:-0}
  local delta_in=$((cur_in - baseline_input))
  local delta_out=$((cur_out - baseline_output))
  (( delta_in < 0 )) && delta_in=0
  (( delta_out < 0 )) && delta_out=0
  printf '%s ↑%s ↓%s' \
    "$(format_elapsed "$elapsed")" \
    "$(format_tokens "$delta_in")" \
    "$(format_tokens "$delta_out")"
}

rename() {
  local emoji="${1:-}" metrics="${2:-}" dir title
  dir=$(tmux display-message -t "$TMUX_PANE" -p '#{b:pane_current_path}' 2>/dev/null) || dir=""
  if [[ -n "$metrics" ]]; then
    title="${emoji:+$emoji }${metrics} ${dir}"
  else
    title="${emoji:+$emoji }${dir}"
  fi
  tmux rename-window -t "$TMUX_PANE" "$title" 2>/dev/null || true
  # Propagate emoji to state so the daemon's next tick uses the latest one.
  [[ -n "$emoji" ]] && set_state current_emoji "$emoji"
}

case "$EVENT" in
  SessionStart)
    tmux set-option -w -t "$TMUX_PANE" automatic-rename off 2>/dev/null || true
    kill_daemon
    clear_state
    rename "$EMOJI_SESSION_START"
    ;;
  SessionEnd)
    kill_daemon
    clear_state
    tmux set-option -w -t "$TMUX_PANE" automatic-rename on 2>/dev/null || true
    ;;
  UserPromptSubmit)
    kill_daemon
    write_initial_state
    rename "$EMOJI_USER_PROMPT_SUBMIT"
    spawn_daemon
    ;;
  PreToolUse)         rename "$EMOJI_PRE_TOOL_USE"          "$(build_metrics_suffix)" ;;
  PostToolUse)        rename "$EMOJI_POST_TOOL_USE"         "$(build_metrics_suffix)" ;;
  PostToolUseFailure) rename "$EMOJI_POST_TOOL_USE_FAILURE" "$(build_metrics_suffix)" ;;
  PermissionRequest)  rename "$EMOJI_PERMISSION_REQUEST"    "$(build_metrics_suffix)" ;;
  Notification)       rename "$EMOJI_NOTIFICATION"          "$(build_metrics_suffix)" ;;
  Stop)               rename "$EMOJI_STOP"                  "$(build_metrics_suffix)" ;;
esac
