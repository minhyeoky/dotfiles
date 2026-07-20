#!/bin/sh
# Apply the stowed spinner quotes to Claude Code's user settings.
# ~/.claude/settings.json is machine-local (absolute paths, per-machine keys),
# so the quotes ship as claude/.claude/spinner-tips.json via stow and this
# script merges them into settings.json as spinnerTipsOverride.
# Idempotent — re-run after editing the tips file. Optional $1 overrides the
# tips file path (useful before the stow link exists).

set -e
command -v jq >/dev/null 2>&1 || { echo "jq is required" >&2; exit 1; }

TIPS=${1:-$HOME/.claude/spinner-tips.json}
SETTINGS=$HOME/.claude/settings.json

[ -f "$TIPS" ] || { echo "tips file not found: $TIPS" >&2; exit 1; }
jq -e '.tips | length > 0' "$TIPS" >/dev/null || {
	echo "invalid tips file (needs non-empty .tips array): $TIPS" >&2
	exit 1
}
[ -f "$SETTINGS" ] || printf '{}\n' >"$SETTINGS"

TMP=$(mktemp)
jq --slurpfile t "$TIPS" '.spinnerTipsOverride = $t[0]' "$SETTINGS" >"$TMP"
cat "$TMP" >"$SETTINGS" # cat-over keeps inode and mode
rm -f "$TMP"
echo "applied $(jq '.tips | length' "$TIPS") spinner tips to $SETTINGS"
