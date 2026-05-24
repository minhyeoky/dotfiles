#!/usr/bin/env bash
# dotfiles-guard — block a commit/push that adds secrets, PII, or dangerous files.
#   content findings : a unified diff on stdin → scan.awk (added lines)
#   filename findings: $GUARD_FILES (newline-separated changed paths) → name denylist
# Usage:  <diff> | GUARD_FILES="$paths" guard.sh <commit|push>
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTEXT="${1:-commit}"

# 1) content scan (added lines)
findings="$(awk -f "$DIR/scan.awk")"; [ $? -eq 0 ] && findings=""

# 2) filename scan — block dangerous files by name (catches binary/odd-format keys)
_allow() { case "$1" in *.pub|*.example|*.sample|*.template|*.dist) return 0;; *) return 1;; esac; }
_deny()  { case "$1" in
    id_rsa|id_dsa|id_ecdsa|id_ed25519|.netrc|.env|.env.*|*.pem|*.key|*.p12|*.pfx|*.jks|*.keystore|*.ppk) return 0;;
    *) return 1;; esac; }
names=""
if [ -n "${GUARD_FILES:-}" ]; then
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    b="${f##*/}"
    _allow "$b" && continue
    _deny "$b"  && names+="  dangerous-filename  $f"$'\n'
  done <<< "$GUARD_FILES"
fi

# 3) gitleaks (best-effort upgrade if installed; only its "leaks found" exit=1 counts)
gl=""
if command -v gitleaks >/dev/null 2>&1; then
  if [ "$CONTEXT" = "commit" ]; then gl="$(gitleaks protect --staged --redact --no-banner 2>/dev/null)"; glrc=$?
  else                               gl="$(gitleaks detect  --redact --no-banner 2>/dev/null)"; glrc=$?; fi
  [ "${glrc:-0}" -ne 1 ] && gl=""
fi

if [ -n "$findings$names$gl" ]; then
  printf '\n\033[1;31m✖ dotfiles-guard: 잠재적 비밀/개인정보 감지 — %s 차단\033[0m\n\n' "$CONTEXT"
  [ -n "$findings" ] && printf '%s\n' "$findings"
  [ -n "$names" ]    && printf '%s\n' "$names"
  [ -n "$gl" ]       && printf '  [gitleaks]\n%s\n\n' "$gl"
  printf '  오탐이면 → 내용은 그 줄에 \033[33mgitguard-ok\033[0m 주석, 또는 \033[33mgit %s --no-verify\033[0m\n\n' "$CONTEXT"
  exit 1
fi
exit 0
