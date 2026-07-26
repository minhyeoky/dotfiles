# my-plugins

Personal Claude Code plugin by Minhyeok Lee. Lives in dotfiles.

## Plugins

### tmux-status

Show Claude Code session status as an emoji, per pane.

| State | Emoji | Meaning |
|-------|-------|---------|
| 🧠 | SessionStart / Thinking | Session active |
| 🚧 | PreToolUse | Executing a tool |
| ❌ | PostToolUseFailure | Tool execution failed |
| 🔓 | PermissionRequest | Waiting for permission |
| 🔔 | Notification | Permission/idle notification |
| ✅ | Stop | Task completed |

Each hook event stamps the matching emoji onto the pane's own `@cc_state` option — no background process or state files. Render it by putting `#{@cc_state}` in `pane-border-format`; the tmux config in this repo does.

The pane, not the window, is the unit because one window can hold several sessions at once (Claude Code splits a pane per teammate). A window name can only show one of them, so the window gets an aggregate instead: the most attention-worthy state among its panes, ordered by `TMUX_STATUS_PRIORITY`, followed by the active pane's title. That keeps a background window's status readable in the tab list, where pane borders are not drawn. `pane_title` is the semantic conversation summary Claude Code sets via OSC escape sequences, falling back to the cwd basename before CC has set it; CJK titles are truncated codepoint-safely.

`$TMUX_PANE` is not used to find the pane — it is inherited by child processes, so a session started by another pane's process would stamp its parent's pane. The hook walks its own process ancestry until a pid matches a `pane_pid` instead.

The original window name is restored when the last session in the window ends (`automatic-rename` is turned off on `SessionStart`, and back on at the `SessionEnd` that leaves no `@cc_state` behind).

**Customization:** Edit `hooks/scripts/tmux-status-config.sh` to change emoji mappings, `TMUX_STATUS_PRIORITY`, or `TMUX_STATUS_TITLE_MAXLEN`.

### main-drift

Warn on `SessionStart` / `UserPromptSubmit` when a tracked remote's default branch has commits the current HEAD does not know about. Silent when there is no drift; fetches are throttled to once per 5 minutes per remote.

**Customization** (per-repo git config wins over env var; unset falls back to the default):

| Setting | git config | Env var | Default |
|---------|-----------|---------|---------|
| Remotes to check | `main-drift.remotes` | `MAIN_DRIFT_REMOTES` | `origin` |
| Branch to track | `main-drift.branch` | `MAIN_DRIFT_BRANCH` | `<remote>/HEAD`, then `main`/`master` probe per remote |

Remotes are space/comma separated and checked in order, e.g. `git config main-drift.remotes "gitlab origin"`. Remotes that do not exist in the repo are skipped silently. The branch setting, when set, applies to every remote.
