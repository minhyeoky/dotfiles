#!/usr/bin/env bash
# Drain Apple Notes "Inbox" folder into org inbox.org, then delete drained notes.
# Staging-inbox workflow: capture on iOS into Apple Notes -> drain at desk -> triage in org.
#
# Safe order: read+format -> append to file -> only then delete the notes
# (deleted notes also land in Apple "Recently Deleted" for 30 days).
#
# Config via env (public-repo safe, no hardcoded personal paths):
#   PKM_DIR             roam/org dir            (default: $HOME/pkm)
#   NOTES_INBOX_FOLDER  Apple Notes folder name (default: Inbox)
set -euo pipefail

INBOX="${PKM_DIR:-$HOME/pkm}/org/inbox.org"
FOLDER="${NOTES_INBOX_FOLDER:-Inbox}"

org="$(mktemp)"; ids="$(mktemp)"; raw="$(mktemp)"
trap 'rm -f "$org" "$ids" "$raw"' EXIT

# --- phase 1: read notes (read-only), structured stream to stdout ---
osascript - "$FOLDER" >"$raw" <<'APPLESCRIPT'
on run argv
  set folderName to item 1 of argv
  set LF to linefeed
  tell application "Notes"
    if not (exists folder folderName of default account) then
      return "ERR:NOFOLDER"
    end if
    set out to ""
    repeat with n in (notes of folder folderName of default account)
      set out to out & "@@ID@@" & (id of n) & LF & "@@BODY@@" & LF & (plaintext of n) & LF & "@@END@@" & LF
    end repeat
    return out
  end tell
end run
APPLESCRIPT

if [ "$(cat "$raw")" = "ERR:NOFOLDER" ]; then
  echo "Apple Notes에 '$FOLDER' 폴더가 없습니다. 메모 앱에서 폴더를 먼저 만드세요." >&2
  exit 1
fi

# --- parse stream -> org entries ($org) + note ids ($ids) ---
awk -v ORG="$org" -v IDS="$ids" '
  /^@@ID@@/   { print substr($0,7) >> IDS; first=1; body=0; next }
  /^@@BODY@@$/{ body=1; next }
  /^@@END@@$/ { print "" >> ORG; body=0; next }
  body==1     { if (first){ print "* " $0 >> ORG; first=0 } else { print "  " $0 >> ORG } }
' "$raw"

if [ ! -s "$org" ]; then
  echo "드레인할 메모 없음 (0)."
  exit 0
fi

# --- phase 2: append to inbox.org (durable) ---
printf '\n' >>"$INBOX"
cat "$org" >>"$INBOX"

# --- phase 3: delete drained notes by id (only after append succeeded) ---
osascript - "$ids" <<'APPLESCRIPT'
on run argv
  set idFile to item 1 of argv
  set idText to read POSIX file idFile as «class utf8»
  set AppleScript's text item delimiters to linefeed
  set idList to text items of idText
  tell application "Notes"
    repeat with theId in idList
      if (theId as text) is not "" then
        try
          delete (every note whose id is (theId as text))
        end try
      end if
    end repeat
  end tell
end run
APPLESCRIPT

n="$(grep -c '^@@ID@@' "$raw" || true)"
echo "드레인 완료: ${n}개 → $INBOX"
