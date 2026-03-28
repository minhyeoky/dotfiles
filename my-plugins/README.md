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

The original window name is restored when the session ends.

**Customization:** Edit `hooks/scripts/tmux-status-config.sh` to change emoji mappings.
