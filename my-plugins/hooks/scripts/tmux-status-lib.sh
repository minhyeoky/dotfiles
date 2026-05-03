#!/usr/bin/env bash
# Shared helpers for tmux-status.sh and tmux-status-daemon.sh. Source-only.

# Sum input/output tokens across DISTINCT assistant messages in a transcript.
# - Dedupes by message.id: Claude streams one logical message as multiple JSONL
#   lines (text block + each tool_use block share the same message.id but get
#   distinct uuids). Without dedupe each turn is counted 1-6×.
# - Drops cache_read_input_tokens: it reports the cumulative cache prefix size
#   at each turn, so summing N turns N-counts the same prefix (~10-30× inflation).
# Echoes "<input> <output>" or "0 0" on any failure.
compute_tokens() {
  local path="${1:-}"
  [[ -n "$path" && -r "$path" ]] || { echo "0 0"; return; }
  jq -rs '
    [.[] | select(.type=="assistant")]
    | unique_by(.message.id // .uuid)
    | map(.message.usage // {})
    | { i: (map((.input_tokens // 0) + (.cache_creation_input_tokens // 0)) | add // 0),
        o: (map(.output_tokens // 0) | add // 0) }
    | "\(.i) \(.o)"
  ' "$path" 2>/dev/null || echo "0 0"
}

# Total elapsed seconds = accumulated + (now - tick_start), or just accumulated
# when frozen (tick_start empty / non-numeric).
compute_elapsed() {
  local acc=${1:-0} tick_start=${2:-} now delta
  [[ "$acc" =~ ^[0-9]+$ ]] || acc=0
  if [[ "$tick_start" =~ ^[0-9]+$ ]]; then
    now=$(date +%s)
    delta=$((now - tick_start))
    (( delta < 0 )) && delta=0
    printf '%d' "$((acc + delta))"
  else
    printf '%d' "$acc"
  fi
}

format_elapsed() {
  local s=$1
  if   (( s < 60 ));   then printf '%ds' "$s"
  elif (( s < 3600 )); then printf '%dm %ds' "$((s / 60))" "$((s % 60))"
  else                      printf '%dh %dm %ds' "$((s / 3600))" "$(( (s % 3600) / 60 ))" "$((s % 60))"
  fi
}

format_tokens() {
  local n=$1
  if   (( n < 1000 ));    then printf '%d' "$n"
  elif (( n < 1000000 )); then awk -v n="$n" 'BEGIN { printf "%.1fk", n/1000 }'
  else                         awk -v n="$n" 'BEGIN { printf "%.1fM", n/1000000 }'
  fi
}

# Walk up the process tree from $PPID, skipping shell wrappers, return the
# first non-shell ancestor PID (= the Claude Code process). Empty on failure.
find_claude_pid() {
  local pid=$PPID comm
  while [ -n "$pid" ] && [ "$pid" != "1" ] && [ "$pid" != "0" ]; do
    comm=$(ps -o comm= -p "$pid" 2>/dev/null | awk '{print $NF}')
    comm=${comm##*/}
    case "$comm" in
      sh|bash|zsh|dash|fish|ksh) ;;
      "") return 1 ;;
      *) printf '%s' "$pid"; return 0 ;;
    esac
    pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
  done
  return 1
}
