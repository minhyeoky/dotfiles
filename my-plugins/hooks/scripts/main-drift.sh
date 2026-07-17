#!/bin/sh
# Default-branch drift detection — SessionStart & UserPromptSubmit hook.
# Warns when origin's default branch has commits the current HEAD does not
# know about (merges from other sessions, web UI, other machines). Silent
# when there is no drift, and silently skips outside a git repo, without an
# origin remote, or when the default branch cannot be resolved — safe on any
# machine this plugin is installed on.
# Fetch is throttled to once per 5 minutes; the stamp lives in the shared
# git common dir so worktrees of the same repo share the throttle.

command -v git >/dev/null 2>&1 || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
git remote get-url origin >/dev/null 2>&1 || exit 0

# Resolve origin's default branch: origin/HEAD if set, else main/master probe.
DEF=$(git symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null)
DEF=${DEF#origin/}
if [ -z "$DEF" ]; then
	for b in main master; do
		if git show-ref -q "refs/remotes/origin/$b"; then DEF=$b; break; fi
	done
fi
[ -n "$DEF" ] || exit 0

COMMON=$(git rev-parse --git-common-dir 2>/dev/null) || exit 0
STAMP="$COMMON/main-drift-fetch-stamp"
if [ ! -f "$STAMP" ] || [ -n "$(find "$STAMP" -mmin +5 2>/dev/null)" ]; then
	GIT_TERMINAL_PROMPT=0 git fetch -q origin "$DEF" 2>/dev/null
	touch "$STAMP"
fi

N=$(git rev-list --count "HEAD..origin/$DEF" 2>/dev/null) || exit 0
[ "${N:-0}" -gt 0 ] || exit 0

echo "[main-drift] origin/$DEF has $N commit(s) unknown to the current HEAD:"
git log --oneline --no-decorate -5 "HEAD..origin/$DEF"
BR=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ "$BR" = "$DEF" ]; then
	echo "→ run git pull to sync."
else
	echo "→ rebase onto origin/$DEF if needed (current branch: $BR). If rule files (CLAUDE.md, memory/) changed, prefer the origin/$DEF version even before rebasing."
fi
exit 0
