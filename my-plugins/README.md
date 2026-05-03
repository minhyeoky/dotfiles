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

Between `UserPromptSubmit` events the title also shows **autonomous-run metrics** — elapsed time and token throughput since the last user prompt:

```
🚧 2m 15s ↑45k ↓4.1k ~/dotfiles
✅ 5m 42s ↑180k ↓12.8k ~/dotfiles
```

`↑` = sum of `input_tokens` + `cache_creation_input_tokens` across distinct assistant messages (deduped by `message.id`; `cache_read_input_tokens` is excluded because it reports the cumulative cache prefix at each turn and double-counts when summed). `↓` = `output_tokens`. Resets on every `UserPromptSubmit`.

A per-session background daemon (`tmux-status-daemon.sh`) refreshes the title every second so elapsed time keeps ticking between hook events. The daemon **self-exits** if any of: state file is removed, the tmux pane disappears, or the parent Claude process dies (`kill -0` check) — preventing zombie processes. It is also explicitly killed on every `UserPromptSubmit` / `SessionStart` / `SessionEnd`.

The original window name is restored when the session ends.

**Customization:** Edit `hooks/scripts/tmux-status-config.sh` to change emoji mappings or set `TMUX_STATUS_SHOW_METRICS=0` to disable the metrics suffix.
