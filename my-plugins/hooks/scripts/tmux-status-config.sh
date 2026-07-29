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

# Order the window chip lists its panes' states in — states that want a person
# come first, so the leftmost glyph in the tab list is the one worth walking to.
# A state that appears here but on no pane is skipped; one on a pane but not here
# is appended at the end.
TMUX_STATUS_PRIORITY="$EMOJI_PERMISSION_REQUEST $EMOJI_NOTIFICATION $EMOJI_POST_TOOL_USE_FAILURE $EMOJI_STOP $EMOJI_USER_PROMPT_SUBMIT $EMOJI_PRE_TOOL_USE $EMOJI_PRE_COMPACT $EMOJI_SESSION_START"
