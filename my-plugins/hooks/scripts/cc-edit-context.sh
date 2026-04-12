#!/usr/bin/env bash
# Record the current session's transcript path to a TTY-keyed registry so that
# nvim (invoked via Ctrl-G → $EDITOR on a claude-prompt-*.md tempfile) can load
# the last assistant response alongside the prompt draft.
#
# Fires on SessionStart. Overwrites on /clear, /resume, /compact — all of which
# re-fire SessionStart with a different source.
set -u

# Walk up the process tree to find the first ancestor with a real controlling
# tty. In most cases this is the immediate parent (Claude Code); we walk up
# just in case stdin/stdout are piped and a direct `ps -o tty= -p $$` returns
# `??`.
tty=""
pid=$$
while [ -n "$pid" ] && [ "$pid" != "1" ] && [ "$pid" != "0" ]; do
  t=$(ps -o tty= -p "$pid" 2>/dev/null | tr -d ' /')
  if [ -n "$t" ] && [ "$t" != "??" ]; then
    tty="$t"
    break
  fi
  pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
done
[ -n "$tty" ] || exit 0

out_dir="${TMPDIR:-/tmp}"
out_dir="${out_dir%/}/cc-edit-context"
mkdir -p "$out_dir" 2>/dev/null || exit 0

jq -c '{transcript_path, session_id, cwd}' \
  > "${out_dir}/${tty}.json" 2>/dev/null || exit 0
