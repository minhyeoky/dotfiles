---
name: vault
description: Save the current conversation result, analysis, or artifact to the personal vault as a self-contained HTML file. Trigger when user says "vault에 저장", "이거 남겨줘", "아카이브해줘", "save to vault", "vault에 남겨줘", or similar. Also proactively suggest saving when a significant deliverable has just been completed (HTML app, structured analysis, research result, working tool).
---

# Vault Skill

Save conversation outputs to the vault directory (`$VAULT_PATH`) as self-contained HTML files.

## VAULT_PATH
The vault directory is given by the `$VAULT_PATH` environment variable, set per-machine in machine-local config (e.g. the `env` block of `~/.claude/settings.json`) — never hardcode a personal path in this repo. **Before anything else, resolve it once** (`printf '%s' "$VAULT_PATH"`) and use that absolute path for every file operation below. If it is unset or empty, stop and ask the user to set `VAULT_PATH` — do not guess a path.

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

## HTML creation (per-entry)
Each individual entry HTML must be **fully self-contained** — no external CDN, no imports.
- Before building, grep `references/patterns.md` for a layout matching the content type (e.g. `grep -iE 'self-check|카탈로그|how-to|입문' references/patterns.md`) and reuse it — that file holds accumulated layout patterns by content type.
- Let content type drive structure: analysis → article layout, mini-app → interactive UI, summary → clean card
- Style freely with inline CSS. Choose typography, colors, layout that best fit the content.
- Must include a descriptive `<title>` tag (shown in browser tab)
- Must be readable and useful when opened standalone in a browser

> `index.html` itself is an **exception** — it loads Pretendard from CDN because its outline + filter UI demands strong Korean readability and information hierarchy. See "index.html structure" below.

## Steps to execute
1. Determine slug from conversation context
2. Write HTML to `$VAULT_PATH/YYYY-MM-DD-<slug>.html`
3. Regenerate `$VAULT_PATH/index.html` (see below)
4. Commit — stage **only the two files you produced** (never `git add .` / `git add -A`; the directory may contain unrelated in-flight HTML from other sessions):
   ```bash
   cd "$VAULT_PATH" && \
     git add YYYY-MM-DD-<slug>.html index.html && \
     git commit -m "vault: <slug>"
   ```
5. Reflect on what you made (see below)

## Entry metadata (type / tag)

Each `<li class="entry">` in `index.html` carries `data-type`, `data-tags`, `data-date` for filtering and outline counts. Decide all three when saving:

**type** — single value from a fixed set:
- `research` — 산업/도메인 입문, 분석, 카탈로그, reference, 비교 doc
- `snapshot` — 설정/상태 캡처 (configs, dotfiles, dashboard, system state)
- `note` — 설계 노트, 회고, 계획, grilling, 의사결정, redesign 기록

If unsure → `note`. Slug hints: `*-snapshot*`→snapshot, `*-stocks-*`/`*-references`/`*-입문`→research, `*-note`/`*-plan`/`*-design`/`*-redesign`/`*-grilling`→note.

**tags** — space-separated kebab-case (Korean OK). 1~2 핵심 도메인. 기존 태그(`주식`, `claude-code`, `career`, `design`, ...) 재사용 우선; 정말 새로운 도메인일 때만 신규 태그.

**date** — filename prefix `YYYY-MM-DD`.

## index.html structure (current)

좌측 sticky outline (overview / months / types / tags) + main column (controls / chips / entries by month) 구조. light paper(`#f8f6f1`) 기본 + `prefers-color-scheme: dark` 자동 전환. Pretendard sans 본문 + JetBrains Mono 메타·뱃지·날짜. Design rationale 전체는 vault entry `2026-05-23-vault-index-redesign.html`.

## index.html 갱신 — single source of truth

`index.html`의 진실은 `<ul id="src">` 하나뿐이다. JS가 정렬·month 그룹핑·chip 카운트·outline 모두 자동 derive. 새 entry 추가는 **이 ul 안에 li 한 줄만** 넣으면 끝.

1. `index.html`을 Read (절대 통째 Write 금지 — learning #79).
2. `<ul id="src">` 안 어디든(위치 무관, JS가 정렬함) 다음 한 줄을 Edit으로 삽입:

   ```html
   <li data-type="<type>" data-tags="<tag1> <tag2>" data-date="YYYY-MM-DD"><a href="YYYY-MM-DD-<slug>.html"><title></a></li>
   ```

   끝. chip / outline / month section / NEW pill / 카운트는 자동 갱신된다.

> **건드리지 말 것:** `<aside>`의 `<ul id="o-*">`, `<div id="chips-type/tag">`의 dynamic chip, `<div id="list">`, `#meta-hint` — 모두 JS가 매 페이지 로드마다 채운다. 손으로 채우면 다음 로드 시 덮어써진다.

검증:
```bash
grep -c '<li data-type=' "$VAULT_PATH/index.html"
# = #src 안의 entries 합계
```

신규 월·신규 태그도 별도 갱신 불필요 — JS가 첫 entry 들어오는 순간 만든다.

## Reflection
After saving, spend a moment evaluating the HTML you just created:
- Was the structure immediately clear?
- Did the visual style fit the content type?
- What would a reader find confusing or missing?
- What would you do differently next time?

If the reflection yields a **reusable, generalizable insight**, append it as one entry (1–2 lines) to `references/patterns.md` — never inline patterns in this file (keeps SKILL.md lean per progressive disclosure). Skip trivial observations.

