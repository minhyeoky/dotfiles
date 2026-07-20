# my-plugins

Personal Claude Code plugin by Minhyeok Lee. Lives in dotfiles.

## Plugins

### tmux-status

Show Claude Code session status as emoji prefix on tmux window name.

| State | Emoji | Meaning |
|-------|-------|---------|
| 🧠 | SessionStart / Thinking | Session active |
| 🚧 | PreToolUse | Executing a tool |
| ❌ | PostToolUseFailure | Tool execution failed |
| 🔓 | PermissionRequest | Waiting for permission |
| 🔔 | Notification | Permission/idle notification |
| ✅ | Stop | Task completed |

The window name is `<emoji> <pane_title>`, where `pane_title` is the semantic conversation summary Claude Code sets via OSC escape sequences (falling back to the cwd basename before CC has set it). Each hook event just re-renames the window with the matching emoji — no background process or state files. CJK titles are truncated codepoint-safely.

The original window name is restored when the session ends (`automatic-rename` is turned off on `SessionStart` and back on at `SessionEnd`).

**Customization:** Edit `hooks/scripts/tmux-status-config.sh` to change emoji mappings or `TMUX_STATUS_TITLE_MAXLEN`.

### main-drift

Warn on `SessionStart` / `UserPromptSubmit` when a tracked remote's default branch has commits the current HEAD does not know about. Silent when there is no drift; fetches are throttled to once per 5 minutes per remote.

**Customization** (per-repo git config wins over env var; unset falls back to the default):

| Setting | git config | Env var | Default |
|---------|-----------|---------|---------|
| Remotes to check | `main-drift.remotes` | `MAIN_DRIFT_REMOTES` | `origin` |
| Branch to track | `main-drift.branch` | `MAIN_DRIFT_BRANCH` | `<remote>/HEAD`, then `main`/`master` probe per remote |

Remotes are space/comma separated and checked in order, e.g. `git config main-drift.remotes "gitlab origin"`. Remotes that do not exist in the repo are skipped silently. The branch setting, when set, applies to every remote.
