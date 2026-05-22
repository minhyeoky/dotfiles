---
name: vault
description: Save the current conversation result, analysis, or artifact to the personal vault as a self-contained HTML file. Trigger when user says "vault에 저장", "이거 남겨줘", "아카이브해줘", "save to vault", "vault에 남겨줘", or similar. Also proactively suggest saving when a significant deliverable has just been completed (HTML app, structured analysis, research result, working tool).
---

# Vault Skill

Save conversation outputs to `~/minhyeoky.github.io/vault/` as self-contained HTML files.

## VAULT_PATH
`~/minhyeoky.github.io/vault/`

## When to proactively suggest
Offer "이거 vault에 저장할까요?" when:
- A complete, interactive HTML app was just built
- A structured analysis or research result reached a natural conclusion
- A significant artifact was produced that has standalone value

Wait for user confirmation before saving.

## File naming
Format: `YYYY-MM-DD-<slug>.html`
- Date: today's date (use current date from context)
- Slug: 2–5 word kebab-case summary, Korean or English
- Examples: `2026-05-22-claude-api-caching.html`, `2026-05-22-tmux-단축키-정리.html`

## HTML creation
Create a **fully self-contained** HTML file — no external CDN, no imports.
- Let content type drive structure: analysis → article layout, mini-app → interactive UI, summary → clean card
- Style freely with inline CSS. Choose typography, colors, layout that best fit the content.
- Must include a descriptive `<title>` tag (used to generate index.html)
- Must be readable and useful when opened standalone in a browser

## Steps to execute
1. Determine slug from conversation context
2. Write HTML to `~/minhyeoky.github.io/vault/YYYY-MM-DD-<slug>.html`
3. Regenerate `~/minhyeoky.github.io/vault/index.html` (see below)
4. Commit:
   ```bash
   cd ~/minhyeoky.github.io && git add vault/ && git commit -m "vault: <slug>"
   ```
5. Reflect on what you made (see below)

## index.html generation
After every save, rebuild `index.html`:
- List all `*.html` files in vault/ except `index.html` itself
- For each file: extract `<title>` tag content, derive date from filename prefix
- Sort newest-first (reverse filename order)
- Style as a clean, well-formatted browsable archive page
- index.html is also fully self-contained (no external deps)

Shell to list vault files:
```bash
ls ~/minhyeoky.github.io/vault/*.html 2>/dev/null | grep -v index.html | sort -r
```

## Reflection
After saving, spend a moment evaluating the HTML you just created:
- Was the structure immediately clear?
- Did the visual style fit the content type?
- What would a reader find confusing or missing?
- What would you do differently next time?

If the reflection yields a **reusable, generalizable insight**, append it to the "Accumulated Learnings" section below. Keep it to 1–2 lines. Skip trivial observations.

---

## Accumulated Learnings

*(Grows as vault saves accumulate. Each entry is a distilled lesson from a past reflection.)*
