#!/usr/bin/env bash
set -uo pipefail

[[ -n "${TMUX_PANE:-}" ]] || exit 0

EVENT="${1:?usage: tmux-status.sh <event_name>}"

source "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/tmux-status-config.sh"

STDIN_JSON=""
if [[ ! -t 0 ]]; then
  STDIN_JSON=$(cat 2>/dev/null || true)
fi

SESSION_ID=""
TRANSCRIPT_PATH=""
if [[ -n "$STDIN_JSON" ]]; then
  parsed=$(printf '%s' "$STDIN_JSON" \
    | jq -r '[.session_id // "", .transcript_path // ""] | @tsv' 2>/dev/null || true)
  IFS=$'\t' read -r SESSION_ID TRANSCRIPT_PATH <<<"$parsed"
fi

STATE_DIR="${TMPDIR:-/tmp}"
STATE_DIR="${STATE_DIR%/}/cc-tmux-status"

state_file() {
  [[ -n "$SESSION_ID" ]] || return 1
  printf '%s/%s.state' "$STATE_DIR" "$SESSION_ID"
}

write_state() {
  local f
  f=$(state_file) || return 0
  mkdir -p "$STATE_DIR" 2>/dev/null || return 0
  printf 'start_epoch=%s\nbaseline_input=%s\nbaseline_output=%s\n' \
    "$1" "$2" "$3" >"$f" 2>/dev/null || return 0
}

read_state() {
  local f
  f=$(state_file) || return 1
  [[ -r "$f" ]] || return 1
  start_epoch=$(grep '^start_epoch=' "$f" | head -1 | cut -d= -f2)
  baseline_input=$(grep '^baseline_input=' "$f" | head -1 | cut -d= -f2)
  baseline_output=$(grep '^baseline_output=' "$f" | head -1 | cut -d= -f2)
  [[ "$start_epoch" =~ ^[0-9]+$ ]] || return 1
  [[ "$baseline_input" =~ ^[0-9]+$ ]] || return 1
  [[ "$baseline_output" =~ ^[0-9]+$ ]] || return 1
  return 0
}

clear_state() {
  local f
  f=$(state_file) || return 0
  rm -f "$f" 2>/dev/null || true
}

# Sum input/output tokens across all assistant messages in the transcript.
# Echoes "<input> <output>" (defaults to "0 0" on any failure).
compute_tokens() {
  local path="${1:-}"
  [[ -n "$path" && -r "$path" ]] || { echo "0 0"; return; }
  jq -rs '
    map(select(.type=="assistant") | .message.usage // {})
    | { i: (map((.input_tokens//0) + (.cache_creation_input_tokens//0)
                + (.cache_read_input_tokens//0)) | add // 0),
        o: (map(.output_tokens//0) | add // 0) }
    | "\(.i) \(.o)"
  ' "$path" 2>/dev/null || echo "0 0"
}

format_elapsed() {
  local s=$1
  if (( s < 60 )); then
    printf '%ds' "$s"
  elif (( s < 3600 )); then
    printf '%dm' "$((s / 60))"
  else
    printf '%dh' "$((s / 3600))"
  fi
}

format_tokens() {
  local n=$1
  if (( n < 1000 )); then
    printf '%d' "$n"
  elif (( n < 1000000 )); then
    awk -v n="$n" 'BEGIN { printf "%.1fk", n/1000 }'
  else
    awk -v n="$n" 'BEGIN { printf "%.1fM", n/1000000 }'
  fi
}

build_metrics_suffix() {
  [[ "${TMUX_STATUS_SHOW_METRICS:-1}" == "1" ]] || return 0
  local start_epoch baseline_input baseline_output
  read_state || return 0
  local now elapsed
  now=$(date +%s)
  elapsed=$((now - start_epoch))
  (( elapsed < 0 )) && elapsed=0
  local tokens cur_in cur_out
  tokens=$(compute_tokens "$TRANSCRIPT_PATH")
  read -r cur_in cur_out <<<"$tokens"
  cur_in=${cur_in:-0}
  cur_out=${cur_out:-0}
  local delta_in=$((cur_in - baseline_input))
  local delta_out=$((cur_out - baseline_output))
  (( delta_in < 0 )) && delta_in=0
  (( delta_out < 0 )) && delta_out=0
  printf '%s ↑%s ↓%s' \
    "$(format_elapsed "$elapsed")" \
    "$(format_tokens "$delta_in")" \
    "$(format_tokens "$delta_out")"
}

reset_baseline() {
  [[ "${TMUX_STATUS_SHOW_METRICS:-1}" == "1" ]] || return 0
  [[ -n "$SESSION_ID" ]] || return 0
  local tokens cur_in cur_out
  tokens=$(compute_tokens "$TRANSCRIPT_PATH")
  read -r cur_in cur_out <<<"$tokens"
  cur_in=${cur_in:-0}
  cur_out=${cur_out:-0}
  write_state "$(date +%s)" "$cur_in" "$cur_out"
}

rename() {
  local emoji="${1:-}"
  local metrics="${2:-}"
  local dir title
  dir=$(tmux display-message -t "$TMUX_PANE" -p '#{b:pane_current_path}' 2>/dev/null) || dir=""
  if [[ -n "$metrics" ]]; then
    title="${emoji:+$emoji }${metrics} ${dir}"
  else
    title="${emoji:+$emoji }${dir}"
  fi
  tmux rename-window -t "$TMUX_PANE" "$title" 2>/dev/null || true
}

case "$EVENT" in
  SessionStart)
    tmux set-option -w -t "$TMUX_PANE" automatic-rename off 2>/dev/null || true
    clear_state
    rename "$EMOJI_SESSION_START"
    ;;
  SessionEnd)
    clear_state
    tmux set-option -w -t "$TMUX_PANE" automatic-rename on 2>/dev/null || true
    ;;
  UserPromptSubmit)
    reset_baseline
    rename "$EMOJI_USER_PROMPT_SUBMIT"
    ;;
  PreToolUse)         rename "$EMOJI_PRE_TOOL_USE"         "$(build_metrics_suffix)" ;;
  PostToolUse)        rename "$EMOJI_POST_TOOL_USE"        "$(build_metrics_suffix)" ;;
  PostToolUseFailure) rename "$EMOJI_POST_TOOL_USE_FAILURE" "$(build_metrics_suffix)" ;;
  PermissionRequest)  rename "$EMOJI_PERMISSION_REQUEST"   "$(build_metrics_suffix)" ;;
  Notification)       rename "$EMOJI_NOTIFICATION"         "$(build_metrics_suffix)" ;;
  Stop)               rename "$EMOJI_STOP"                 "$(build_metrics_suffix)" ;;
esac
