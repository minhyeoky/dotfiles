#!/bin/sh
# Link the no-mistakes global config into ~/.no-mistakes.
# no-mistakes/ is deliberately not a stow package: if ~/.no-mistakes does not
# exist at stow time, stow folds the whole directory into a symlink pointing
# at this repo, and the daemon would then write its runtime state (SQLite,
# logs, disposable worktrees of gated repos) inside a public repository.
# So: create the real directory first, link the one config file.
set -e
SRC=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)/no-mistakes/config.yaml
mkdir -p "$HOME/.no-mistakes"
ln -sf "$SRC" "$HOME/.no-mistakes/config.yaml"
echo "linked ~/.no-mistakes/config.yaml -> $SRC"
if ! command -v no-mistakes >/dev/null 2>&1; then
	cat <<'EOF'
no-mistakes binary not installed. Preferred install (source build, no
embedded telemetry ID):
  go install github.com/kunchenguid/no-mistakes/cmd/no-mistakes@latest
Then per repo: no-mistakes init
EOF
fi
