---
name: handoff
description: Compact the current conversation into a handoff document for another agent to pick up.
argument-hint: "What will the next session be used for?"
---

Write a handoff document summarising the current conversation so a fresh agent can continue the work.

## Where to save

Save to `$VAULT_PATH/handoffs/YYYY-MM-DD-<slug>.md`. The vault directory is given by the `$VAULT_PATH` environment variable, set per-machine in machine-local config (e.g. the `env` block of `~/.claude/settings.json`) — never hardcode a personal path in this repo. **Resolve it once first** (`printf '%s' "$VAULT_PATH"`). If it is unset or empty, stop and ask the user to set `VAULT_PATH` — do not guess a path, and do not silently fall back to a temp dir (a handoff may need to outlive an OS cleanup or reboot).

- Create the subdir if missing: `mkdir -p "$VAULT_PATH/handoffs"`.
- Filename: today's date + a 2–5 word kebab-case slug, e.g. `2026-05-30-auth-refactor.md`.
- Keep it **markdown** — this is a working document for the next agent, not a vault display artifact.
- Do **not** touch `$VAULT_PATH/index.html`. Handoffs live under `handoffs/` and stay out of the vault index; only curated, standalone deliverables belong in the index (that is the `vault` skill's job).
- To persist it in history, commit only the file you wrote (`cd "$VAULT_PATH" && git add handoffs/YYYY-MM-DD-<slug>.md && git commit -m "handoff: <slug>"`) — never `git add .` / `git add -A`.

## Contents

Include a "suggested skills" section in the document, which suggests skills that the agent should invoke.

Do not duplicate content already captured in other artifacts (PRDs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.

Redact any sensitive information, such as API keys, passwords, or personally identifiable information.

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the doc accordingly.

<!-- Source: mattpocock/skills (MIT) — https://github.com/mattpocock/skills/blob/main/skills/productivity/handoff/SKILL.md -->
