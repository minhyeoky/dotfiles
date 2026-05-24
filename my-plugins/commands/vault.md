---
description: Save current conversation result or artifact to the vault ($VAULT_PATH) as a self-contained HTML file
allowed-tools: Write, Bash, Read
---

Save the current conversation's main result, analysis, or artifact to the vault.

Follow the vault skill behavior exactly:
1. Resolve `$VAULT_PATH` (`printf '%s' "$VAULT_PATH"`); if it is unset or empty, stop and ask the user to set it — do not guess a path.
2. Determine the best slug from the conversation context (or use $ARGUMENTS as a title hint if provided)
3. Create a fully self-contained HTML file at `$VAULT_PATH/YYYY-MM-DD-<slug>.html`
4. Regenerate `$VAULT_PATH/index.html`
5. Run: `cd "$VAULT_PATH" && git add YYYY-MM-DD-<slug>.html index.html && git commit -m "vault: <slug>"`
6. Reflect on what you made and append a reusable insight to the vault skill's `references/patterns.md` if there's one

$ARGUMENTS
