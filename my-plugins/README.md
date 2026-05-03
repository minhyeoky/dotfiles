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
🚧 2m ↑45k ↓4.1k ~/dotfiles
✅ 5m ↑180k ↓12.8k ~/dotfiles
```

`↑` = input (`input_tokens` + cache reads + cache creation), `↓` = `output_tokens`. Resets on every `UserPromptSubmit`. The displayed value freezes after `Stop` until the next prompt — it is the **lower bound** of the true `UserPromptSubmit`→`UserPromptSubmit` interval.

The original window name is restored when the session ends.

**Customization:** Edit `hooks/scripts/tmux-status-config.sh` to change emoji mappings or set `TMUX_STATUS_SHOW_METRICS=0` to disable the metrics suffix.
