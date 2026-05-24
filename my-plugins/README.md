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
