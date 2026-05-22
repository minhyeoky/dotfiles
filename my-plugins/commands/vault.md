---
description: Save current conversation result or artifact to ~/minhyeoky.github.io/vault/ as a self-contained HTML file
allowed-tools: Write, Bash, Read
---

Save the current conversation's main result, analysis, or artifact to the vault.

Follow the vault skill behavior exactly:
1. Determine the best slug from the conversation context (or use $ARGUMENTS as a title hint if provided)
2. Create a fully self-contained HTML file at `~/minhyeoky.github.io/vault/YYYY-MM-DD-<slug>.html`
3. Regenerate `~/minhyeoky.github.io/vault/index.html`
4. Run: `cd ~/minhyeoky.github.io && git add vault/ && git commit -m "vault: <slug>"`
5. Reflect on what you made and update `~/dotfiles/my-plugins/skills/vault/SKILL.md` if there's a reusable insight

$ARGUMENTS
