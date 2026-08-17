# my-plugins

Personal Claude Code plugin by Minhyeok Lee. Lives in dotfiles.

## Plugins

### tmux-status

Show Claude Code session status as an emoji: per pane on the pane border, and per window in the tab list.

| Emoji | Event | Meaning |
|-------|-------|---------|
| 🌱 | `SessionStart` | Session opened |
| 🧠 | `UserPromptSubmit`, `PostToolUse` | Thinking |
| 🚧 | `PreToolUse` | Executing a tool |
| ❌ | `PostToolUseFailure` | Tool execution failed |
| 🔓 | `PermissionRequest`, `Notification: permission_prompt` | Waiting for permission |
| 🔔 | `Notification: idle_prompt` | Waiting for input |
| 📦 | `PreCompact` | Compacting the context |
| ✅ | `Stop` | Turn finished |

Each hook event stamps the matching emoji onto the pane's own `@cc_state` option, and writes nothing else — no window-level value, no background process, no state files. Render it by putting `#{@cc_state}` in `pane-border-format`, and `#{P:#{@cc_state}}` in `window-status-format` to get the window's whole set; the tmux config in this repo does both (through `@cc_live` and `@cc_chip`, which add the dead-session filter described below).

Permission waiting is reached by two different events depending on the build, so both are mapped to 🔓 and only `idle_prompt` keeps 🔔. Mapping the pair to one emoji would collapse them: whichever fired last would win, and one of the two states could never be seen.

The pane, not the window, is the unit of state because one window can hold several sessions at once (Claude Code splits a pane per teammate). A pane option is also the only place the state survives tmux moving the pane: `break-pane`, `join-pane` and `swap-pane` all carry `pane_id` and its options along, so maximizing a pane — which in oh-my-tmux is `new-window` plus `swap-pane`, not zoom — never separates a session from its state.

The tab list still needs a per-window answer, and it is derived rather than stored. `#{P:...}` loops the window's panes when the status bar is drawn, giving one glyph per live session in pane order — `🔓🔓🧠✅` is four sessions, the first two blocked on permission. A hook-maintained window aggregate cannot be right here: one of its inputs is tmux moving a pane between windows, which no Claude Code event reports, so a break, a maximize or a pane dying without `SessionEnd` would each leave the tab wrong with nothing to correct it. A value that is never stored cannot go stale. Repetition also carries the count without the priority order a deduplicated `🔓2🧠✅` would need; it is not a position handle, though, since a pane holding no session contributes no glyph — the pane border is what carries identity.

The chip sits in front of `#W` rather than replacing it, so `automatic-rename` keeps working; an earlier version renamed the window and had to turn `automatic-rename` off to do it.

Cross-window attention also rides the terminal bell, which reddens the window in the tab list. That is what tells you a window wants you at all; the chip is what tells you why. The bell needs `preferredNotifChannel: "terminal_bell"` in Claude Code settings, plus `monitor-bell on` and a `window-status-format` that branches on `window_bell_flag`; the tmux config in this repo does both.

State is cleared on `SessionEnd`, which a crashed session never reaches, so a pane can be left holding the emoji of a session that is gone. Both renderings therefore ignore state on a pane whose foreground command is a shell, by reading `@cc_live` (defined in this repo's tmux config) instead of `@cc_state` directly — the pane border directly, the tab list once per pane inside the loop. Tool calls do not take the terminal foreground, so a busy session is never mistaken for a dead one.

`$TMUX_PANE` is not used to find the pane — it is inherited by child processes, so a session started by another pane's process would stamp its parent's pane. The hook walks its own process ancestry until a pid matches a `pane_pid` instead, and marks nothing at all if that fails: stamping the wrong pane is worse than stamping none.

**Customization:** Edit `hooks/scripts/tmux-status-config.sh` to change emoji mappings.

### main-drift

Warn on `SessionStart` / `UserPromptSubmit` when a tracked remote's default branch has commits the current HEAD does not know about. Silent when there is no drift; fetches are throttled to once per 5 minutes per remote.

**Customization** (per-repo git config wins over env var; unset falls back to the default):

| Setting | git config | Env var | Default |
|---------|-----------|---------|---------|
| Remotes to check | `main-drift.remotes` | `MAIN_DRIFT_REMOTES` | `origin` |
| Branch to track | `main-drift.branch` | `MAIN_DRIFT_BRANCH` | `<remote>/HEAD`, then `main`/`master` probe per remote |

Remotes are space/comma separated and checked in order, e.g. `git config main-drift.remotes "gitlab origin"`. Remotes that do not exist in the repo are skipped silently. The branch setting, when set, applies to every remote.
