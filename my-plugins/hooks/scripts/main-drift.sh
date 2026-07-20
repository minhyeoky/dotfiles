#!/bin/sh
# Default-branch drift detection — SessionStart & UserPromptSubmit hook.
# Warns when a tracked remote's default branch has commits the current HEAD
# does not know about (merges from other sessions, web UI, other machines).
# Silent when there is no drift, and silently skips outside a git repo, when
# no configured remote exists, or when a default branch cannot be resolved —
# safe on any machine this plugin is installed on.
# Fetch is throttled to once per 5 minutes per remote; the stamps live in the
# shared git common dir so worktrees of the same repo share the throttle.
#
# Remotes to check (first match wins; space/comma separated, checked in order):
#   1. per-repo git config:   git config main-drift.remotes "gitlab origin"
#   2. env var:               MAIN_DRIFT_REMOTES="gitlab origin"
#   3. default:               origin
# Branch to track, applied to every remote (first match wins):
#   1. per-repo git config:   git config main-drift.branch <name>
#   2. env var:               MAIN_DRIFT_BRANCH=<name>
#   3. per remote: <remote>/HEAD, then main/master probe.

command -v git >/dev/null 2>&1 || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

REMOTES=$(git config --get main-drift.remotes 2>/dev/null)
[ -n "$REMOTES" ] || REMOTES=${MAIN_DRIFT_REMOTES:-}
[ -n "$REMOTES" ] || REMOTES=origin
REMOTES=$(printf '%s' "$REMOTES" | tr ',' ' ')

CFG_BRANCH=$(git config --get main-drift.branch 2>/dev/null)
[ -n "$CFG_BRANCH" ] || CFG_BRANCH=${MAIN_DRIFT_BRANCH:-}

COMMON=$(git rev-parse --git-common-dir 2>/dev/null) || exit 0
BR=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

for R in $REMOTES; do
	git remote get-url "$R" >/dev/null 2>&1 || continue

	# Resolve the branch to track for this remote. Explicit config wins —
	# the mainline branch varies by environment and policy.
	DEF=$CFG_BRANCH
	if [ -z "$DEF" ]; then
		DEF=$(git symbolic-ref -q --short "refs/remotes/$R/HEAD" 2>/dev/null)
		DEF=${DEF#"$R"/}
	fi
	if [ -z "$DEF" ]; then
		for b in main master; do
			if git show-ref -q "refs/remotes/$R/$b"; then DEF=$b; break; fi
		done
	fi
	[ -n "$DEF" ] || continue

	# Per-remote stamp: one unreachable remote must not starve the others.
	STAMP="$COMMON/main-drift-fetch-stamp-$R"
	if [ ! -f "$STAMP" ] || [ -n "$(find "$STAMP" -mmin +5 2>/dev/null)" ]; then
		GIT_TERMINAL_PROMPT=0 git fetch -q "$R" "$DEF" 2>/dev/null
		touch "$STAMP"
	fi

	N=$(git rev-list --count "HEAD..$R/$DEF" 2>/dev/null) || continue
	[ "${N:-0}" -gt 0 ] || continue

	echo "[main-drift] $R/$DEF has $N commit(s) unknown to the current HEAD:"
	git log --oneline --no-decorate -5 "HEAD..$R/$DEF"
	if [ "$BR" = "$DEF" ]; then
		echo "→ run git pull $R $DEF to sync."
	else
		echo "→ rebase onto $R/$DEF if needed (current branch: $BR). If rule files (CLAUDE.md, memory/) changed, prefer the $R/$DEF version even before rebasing."
	fi
done
exit 0
