#!/usr/bin/env bash
# dotfiles-guard.
#   (no arg)  activate on THIS machine — git does not auto-enable tracked hooks.
#   audit     scan the FULL history for already-committed secrets/PII (one-off).
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR/.."

if [ "${1:-}" = "audit" ]; then
  echo "full-history audit (이미 커밋된 secret/PII 점검)…"
  git log -p --all -U0 | awk -f "$DIR/scan.awk" || true
  echo "— audit done (위 출력이 없으면 클린)."
  exit 0
fi

git config core.hooksPath .githooks
chmod +x "$DIR"/pre-commit "$DIR"/pre-push "$DIR"/guard.sh "$DIR"/install.sh
echo "✓ dotfiles-guard 활성화됨 (core.hooksPath=.githooks)"
