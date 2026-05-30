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
5. 검증 게이트 3개를 통과 (see "검증 게이트" below) — 통과 전엔 작업을 "완료"로 보지 않는다

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

각 entry는 제목을 `" — "`(공백+em-dash+공백) 기준으로 **head(굵게) + desc(dim 2줄 클램프)** 2단 카드로 JS가 자동 분리(ive 메인 인덱스의 title+summary 카드와 동형). 따라서 제목은 `<핵심 제목> — <한 줄 설명>` 형태로 쓰면 카드가 가장 잘 읽힌다. `—`가 없으면 제목만 한 줄로 표시(정상).

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

## 검증 게이트 (저장·커밋 후 필수)

작업을 "완료"로 간주하기 전에 아래 3개 게이트를 순서대로 통과시킨다. 통과 못 하면 고치고 다시 본다.

### Gate 1 — 보안 (공개 누수 차단)
`references/patterns.md`는 **dotfiles 공개 레포의 추적 파일**이다. 여기로 새는 순간 영구 공개된다.
- **patterns.md append 자가검열**: Gate 3에서 patterns.md에 적을 교훈에 *개인 구체값*이 섞였는지 점검 — 종목·티커·수치, 거주지·지역명, 금전·매출 목표, 제품/서비스 고유명, 내면·관계. 하나라도 있으면 generic 예시("정량 자산 카드", "지역 특화 정보")로 치환한 **뒤에만** append. 레이아웃/구조 규칙만 적는다.
- **스테이징 범위**: vault 커밋에 의도한 2개 파일(`YYYY-MM-DD-<slug>.html`, `index.html`)만 들어갔는지 `git -C "$VAULT_PATH" show --stat HEAD`로 확인 — 다른 세션의 in-flight HTML 혼입 방지.
- entry 본문의 개인 콘텐츠는 OK(`$VAULT_PATH`는 비공개) — 누수 경계는 어디까지나 patterns.md다.

### Gate 2 — 연결성 & 회고
- 이 entry가 기존 vault 문서와 이어지나? 같은 주제·시리즈·후속이면 footer cross-link, 또는 `-plan`/`-shortlist` 같은 페어링을 건다. 거의-중복이면 새 파일 말고 원본에 addendum(앞 룰).
- 여러 문서를 가로지르는 **메타 인사이트**가 보이면, 그것 자체를 새 entry나 patterns.md 교훈(레이아웃 한정)으로 남길지 판단한다.

### Gate 3 — 내용 검토 & 스킬 개선
- 저장한 HTML을 다시 보고: 구조가 즉시 명확한가? 시각 스타일이 콘텐츠 타입에 맞나? 독자가 헷갈리거나 빠진 부분은? 다음엔 무엇을 다르게?
- **재사용 가능한 일반화 인사이트**가 나오면 `references/patterns.md`에 한 줄(1–2줄)로 append — Gate 1 자가검열을 반드시 거친다. 절대 SKILL.md에 inline 금지(progressive disclosure). 사소한 관찰은 skip.
- 이번 작업이 **스킬 자체의 개선 기회**를 드러냈나? (반복되는 수작업, 빠진 content-type 패턴, 더 나은 JS derive, index 구조 등) → 절차 개선은 SKILL.md에, 레이아웃 개선은 patterns.md에 반영을 제안한다.

