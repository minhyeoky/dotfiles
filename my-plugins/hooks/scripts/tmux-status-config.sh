# cc-tmux-status emoji config
# Customize emojis by editing this file.

EMOJI_SESSION_START="🌱"
EMOJI_USER_PROMPT_SUBMIT="🧠"
EMOJI_PRE_TOOL_USE="🚧"
EMOJI_POST_TOOL_USE="🧠"
EMOJI_POST_TOOL_USE_FAILURE="❌"
EMOJI_PERMISSION_REQUEST="🔓"
EMOJI_NOTIFICATION="🔔"
EMOJI_STOP="✅"
EMOJI_PRE_COMPACT="📦"

# Which state wins the window name when one window holds several sessions.
# The first match in this list is used, so order it by how much attention the
# state deserves.
TMUX_STATUS_PRIORITY="🔓 🔔 ❌ 📦 🚧 🧠 🌱 ✅"

# Max characters for the pane-title segment of the window name. Truncated
# overflow gets a trailing "…". Kept short because the pane border already
# carries the full title; the window name only has to stay recognizable in
# the tab list.
TMUX_STATUS_TITLE_MAXLEN=25
