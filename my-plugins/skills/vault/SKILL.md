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

## HTML creation (per-entry)
Each individual entry HTML must be **fully self-contained** — no external CDN, no imports.
- Let content type drive structure: analysis → article layout, mini-app → interactive UI, summary → clean card
- Style freely with inline CSS. Choose typography, colors, layout that best fit the content.
- Must include a descriptive `<title>` tag (shown in browser tab)
- Must be readable and useful when opened standalone in a browser

> `index.html` itself is an **exception** — it loads Pretendard from CDN because its outline + filter UI demands strong Korean readability and information hierarchy. See "index.html structure" below.

## Steps to execute
1. Determine slug from conversation context
2. Write HTML to `~/minhyeoky.github.io/vault/YYYY-MM-DD-<slug>.html`
3. Regenerate `~/minhyeoky.github.io/vault/index.html` (see below)
4. Commit — stage **only the two files you produced** (never `git add vault/`; the directory may contain unrelated in-flight HTML from other sessions):
   ```bash
   cd ~/minhyeoky.github.io && \
     git add vault/YYYY-MM-DD-<slug>.html vault/index.html && \
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
grep -c '<li data-type=' ~/minhyeoky.github.io/vault/index.html
# = #src 안의 entries 합계
```

신규 월·신규 태그도 별도 갱신 불필요 — JS가 첫 entry 들어오는 순간 만든다.

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

- **설계 노트는 Q&A 카드 형태가 효과적.** 결정 사항이 많을 때 `<div class="decision">` 블록으로 질문/답 구조를 만들면 나중에 읽기 쉽다.
- **index.html은 `<title>` 태그 파싱으로 재생성.** 파일마다 별도 메타데이터 없이 title만으로 충분히 깔끔한 아카이브 페이지를 만들 수 있다.
- **설정/스냅샷류는 grid + key-value 카드가 적합.** 정량 데이터(boolean 토글, 값, 모드)는 텍스트로 풀어쓰지 말고 `auto-fill minmax(220px, 1fr)` 그리드의 KV 카드로 배치하면 한 눈에 스캔 가능.
- **이벤트/파이프라인 흐름은 `label → arrow → target` 구조.** Hook chain 같은 순차적 흐름은 좌측 라벨(이벤트명) · 중앙 화살표 · 우측 타겟의 단순 3열로 시각화하면 다이어그램 없이도 흐름이 읽힌다.
- **섹터/도메인 입문 글은 `TL;DR → 30초 사전지식 → 기술 분류표 → 촉매(데이터 포함) → 종목 카드 → Bull/Bear 2열 → 운용 포인트` 순서가 잘 먹는다.** 사용자가 비전문가일 때, 그가 이미 아는 도메인(예: SWE → ISA 비유)으로 분류 체계를 매핑하면 이해 속도가 크게 올라간다.
- **연속 섹터 정리는 마지막에 "이전 글과의 비교 표"를 붙여라.** vault에 이미 비슷한 카테고리 글이 있으면, 새 글 마지막에 `축 × 두 섹터` 형태의 6~8행 표로 연결하면 독자가 새 정보를 기존 멘탈 모델에 끼워 넣기 쉽다.
- **기존 vault 항목 업데이트는 새 파일 대신 inline addendum.** 같은 주제의 후속 분석은 새 날짜 파일을 만들기보다 원본에 `<hr>` + 새 `<header>` 블록으로 이어 붙이면 컨텍스트가 한 곳에 모인다. 날짜는 달라도 **같은 날(same-day) 후속도 addendum이 맞다** — 거의-중복 새 파일을 만들지 말 것. 효과를 극대화하려면 (1) 섹션 numbering을 원본에서 이어받고(예: 01~05 → 06~), (2) 원본의 semantic color class(`.verdict/.vrow`, `tr.variance/.opportunity/.ruin`, `.calc .pos/.neg`)를 그대로 재사용하면 addendum이 bolt-on이 아니라 한 문서로 읽힌다. index.html 재생성 불필요(제목이 여전히 맞으면 손대지 말 것), 커밋은 그 한 파일만 스테이징 + 메시지에 "addendum" 명시.
- **index.html은 통째로 Write하지 말고 항상 Read 후 Edit으로 surgical 갱신.** 사용자가 index.html을 직접 커스터마이즈하는 경우가 있다(badges/tags/month grouping/카운트 등). 매번 통째 재생성하면 사용자 작업이 사라진다. 새 항목 추가는 (1) Read로 현재 구조 확인 (2) 적절한 위치에 `<li>` Edit으로 삽입 (3) 카운트 필드 갱신. "regenerate"는 fallback일 뿐이고 default는 incremental edit.
- **참고/리퍼런스 doc는 featured 카드 + 보조 카드 + "★ why" 주석 패턴이 효과적.** 외부 레포·도구를 다수 나열할 때, 핵심 1~2개는 `.featured` 클래스로 강조(그라데이션 배경, 컬러 보더)하고 나머지는 plain card. 각 카드 하단에 `★ ` 프리픽스로 "왜 주목할 가치 있는가" 1줄 주석을 별색(녹색 톤)으로 붙이면 사용자가 자기 컨텍스트와 매칭해서 빠르게 스캔 가능.
- **"넓은 카탈로그 doc" + "특정 소스 필터 doc"의 쌍은 자연스러운 시리즈를 만든다.** 한 주제로 broad reference를 한 번 만들고, 이어서 같은 주제를 특정 소스(news.hada.io / HN / arxiv 등)로 필터링한 후속 doc을 만들면, 두 doc이 footer에서 서로 cross-link되어 "전체 풍경 → 국지적 시그널" 두 단계 탐색이 가능. 후속 doc은 source ID(예: GeekNews topic id)를 leftmost 컬럼으로 노출하면 tabular feel + 빠른 navigation.
- **진행 중 grilling/planning 노트는 "decided" vs "open" 두 상태 카드로 시각 구분.** 좌측 보더 색(decided=녹색, open=주황)과 `.dec-tag` 의 status 라벨로 닫힌 결정과 미해결 질문을 한 페이지에서 분리. 각 카드는 `Q번호 · subcategory · status` 메타 + 질문 + `→ <span class="pick">선택지</span>` + 근거 구조. 세션이 끝나기 전에도 중간 상태를 vault에 남길 수 있어 멀티세션 워크플로우와 잘 맞음. 추가로 결정 카드 위에 KV 그리드 `프로필 스냅샷`을 두면 후속 독자(또는 미래의 자기)가 컨텍스트를 빠르게 복원.
- **Redesign/iteration류 노트는 "before↔after ASCII 비교 + iteration 카드(변경+self-critique) + 핵심 코드 스니펫" 패턴이 효과적.** 결과만 나열하지 말고 라운드별 결정 사유와 그 라운드의 부족함(self-critique)을 카드로 분리하면 progression이 추적 가능 — 다음 iteration의 trigger를 명시적으로 남긴다. 디자인 노트 자체를 노트가 설명하는 그 디자인 시스템으로 만들면(예: light paper + Pretendard 본문 + Mono 메타) 메타-설명력이 올라가고 reference 구현으로도 작동.
- **운영 절차의 비효율은 single-source-of-truth + JS derive로 흡수한다.** index.html 같은 "데이터 + view" 페이지는 chip 카운트·outline·month section·NEW pill 등 derive 가능한 모든 필드를 정적으로 박지 말고 JS가 한 source(`<ul id="src">`)에서 계산해 채우게 한다. 운영 절차가 "8지점 갱신 → 1줄 추가"로 축소되고, 카운트 불일치 risk가 영구적으로 사라진다. 사적/소규모 페이지면 JS-off fallback은 ul 한 개라 거의 무료. 통째 Write 금지(learning #79)는 여전히 유효하지만, surgical edit의 대상이 더 작아진다.
- **메타 분석/도입 결정 노트는 "rules 그리드 + 대조 테이블 + decided 카드 + 액션 체크리스트" 조합이 강력.** 외부 도구·라이브러리·스킬을 우리 setup에 흡수할지 검토할 때 ① 외부 규칙을 카드 그리드로 압축(`auto-fit minmax`), ② 우리 현재 상태와 규칙 단위 ✓/⚠ 대조 테이블, ③ `decided` 카드(좌측 녹색 보더 + `.dec-tag`)로 결정 + 근거 한 문단, ④ 즉시 실행 가능한 명령 포함 액션 체크리스트(번호 매김) — 네 영역이 한 페이지에서 "외부 패턴 → 진단 → 결정 → 실행"의 완결 사이클을 보여준다. write-a-skill 같은 메타스킬 검토에 특히 잘 맞고, 후속 도입 검토 노트의 템플릿으로 재사용 가능.
- **여러 primer를 묶는 종합 doc은 "티어 색상 시스템 + 가로 allocation bar + thesis-breaking 체크리스트"로 구조화.** 카테고리(Core/Satellite/Speculative)에 일관된 색(녹/노/빨)을 CSS 변수로 박고 ① 종목 카드 좌측 보더 ② pill 라벨 ③ 가로 stacked bar 모두 같은 색으로 동기화하면 분류가 시각적으로 즉시 읽힘. 끝부분에 "이 조건이 트리거되면 thesis 깨짐" empty-checkbox 리스트(`☐` ::before)를 두면 단순 분석을 넘어 운용 가능한 문서가 됨. Footer에 베이스가 된 vault 항목들을 cross-link하면 다음 독자가 출처를 한 번에 추적 가능.
- **카탈로그 doc은 분류 축이 가치를 좌우한다 — "사용자 셋업과의 매칭" 축이 가장 강력.** awesome-list 형태로 "공식 vs 큐레이션 vs 회사 mega-pack"으로 자르면 단순 카탈로그에 그치지만, "structure-match · dual-env match · 도메인 일치"처럼 사용자의 본인 셋업과의 거리로 자르면 actionable해진다. doc 끝에는 반드시 <strong>"옮겨올 implementable picks" 섹션</strong>을 둬서 흥미→행동 다리를 놓을 것 (각 픽에 `<code>아이템</code> <span class="from">from 원본</span>` 구조로 출처와 함께). 사용자가 "이런 거 원했어"라고 다른 축을 신호하면 즉시 rewrite — 카탈로그는 잘못 분류되면 거의 무가치.
- **개념/용어 해부 explainer는 "N개 변종에 일관된 색을 박고 여러 표현(표 → 질문 카드 → verdict 행)에 동기화"하는 패턴이 강력.** 한 단어(예: "risk")가 사실 N개의 다른 정의로 쓰임을 보일 때, 각 변종(variance/opportunity/ruin)에 CSS 변수 색을 하나씩 배정하고 ① 분류 표의 행 ② "각자 묻는 질문" 카드 ③ 최종 verdict 행에 같은 색을 반복하면 독자가 색만으로 변종을 추적. 정량 비교(앙상블 vs 시간 평균 같은)는 `.calc` 모노스페이스 블록에 색칠한 숫자로 단계별 노출하면 수식 없이도 직관이 전달됨. 마지막 callout `한 줄 요약`으로 closure. 비전문가용 개념 글의 재사용 템플릿.
- **"verbatim 캡처 + 해부" 혼합 doc은 fidelity 경계를 시각적으로 표시하라.** 시스템 프롬프트·설정처럼 일부는 원문 그대로, 일부는 설명인 문서는 ① verbatim 블록에 `vtag`(static=녹 / dynamic=주황) 라벨 + 좌측 보더 색으로 "이건 실제 텍스트"임을 명시하고, ② 동적/주입 부분(사용자 본인 파일 — CLAUDE.md, MEMORY.md, gitStatus 등)은 통째 재수록 말고 출처 표로 가리킨다(bloat 방지 + 소유권 존중). 조직 축은 7개 나열보다 직교하는 "static vs dynamic" 한 줄이 강력 — 색-코딩이 표·태그·보더에 일관 동기화되면 독자가 색만으로 구운 것 vs 주입된 것을 추적. 개념 비교(harness vs persona 등)는 2열 `.card`, 위험 원칙(blast radius)은 `.callout` 1개로 닫음.
- **테제 검증/de-bias(self-check) 노트는 "테제 callout → SUPPORTS/CONTRADICTS 색코딩 카드 → perception-bias 메타 callout → 보정 테제 + 할인율 split-bar → 증거품질 그리드" 구조가 강력.** 살아남은 발견(녹 보더 `.s`)과 무너진 발견(빨 보더 `.c`)을 `SUPPORTS`/`CONTRADICTS` pill로 라벨링하고 각 카드에 1차/2차 출처를 `.src` 모노 라벨로 노출하면 신뢰도가 함께 읽힌다. 핵심 장치 둘: ① **할인율 split-bar** — 원 테제를 몇 % 깎는지를 `유지%`(녹)/`폐기%`(빨) 두 색 바로 수치화(단순 결론보다 강한 closure). ② **증거품질 그리드** — `firm`(1차)/`soft`(2차 미검증)/`disputed`(인과 논쟁)를 상단 보더 색이 다른 KV 카드로 분리해 "근거 자체도 검증했음"을 보여줌. fan-out 수렴(아래)이 발견 *수집*용이면, 이건 발견을 *판결*하는 용도.
- **Fan-out 결과 수렴 doc은 "클러스터 strip → 합집합 tier 카드 → 키워드 빈도 표 → 약점 체크리스트" 4단 구조.** 여러 sub-agent가 횡으로 흩어 수집한 raw output을 vault에 다시 모을 때: ① flex-proportional `.strip`으로 클러스터별 발견 수 분포를 즉시 보여주고 ② **클러스터 경계를 무시하고 S/A/B tier로 재정렬**해 큰 카드로 노출(클러스터는 우측 colored tag로만 남김) ③ 4 클러스터 키워드를 합산한 frequency 표에 "본인 매칭(강/중/약)" 컬럼을 붙이면 객관적 신호와 자기 평가가 동시에 보임 ④ 약점 보완 체크리스트로 closure. tier 카드 안에 `<span class="tag">키워드</span>` pill 1-2개를 메모 앞에 박으면 fit 근거가 즉시 노출. 다음 단계(Phase N)로 넘어가는 시사점을 footer 직전에 짧게 정리. 사용자 의사결정 노트(`-plan.html`)와 결과 수렴 노트(`-shortlist.html`)는 한 쌍으로 짝지어 두면 grilling 세션의 입력/출력이 vault에 보존됨.
