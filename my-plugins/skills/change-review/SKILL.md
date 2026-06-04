---
name: change-review
description: Generate a self-contained interactive before/after review tool (HTML) so a human can sign off on many proposed changes asynchronously. Each change becomes a card with before(red)/after(green), a 확정/수정/보류 decision pill, and a memo; a "피드백 복사" button exports all decisions as text to paste back. Trigger when you have a batch of proposed edits/designs/decisions for the user to review, or when the user says "변경 리뷰 만들어줘", "before/after 리뷰", "교정 리뷰 도구", "리뷰 카드로 보여줘", "review tool".
---

# change-review

When you propose many changes at once (copy edits, design tweaks, refactors, term renames), don't make the user scroll a wall of diffs in chat. Emit an **interactive review artifact**: one card per change, the user clicks a decision + writes a memo, then hits **피드백 복사** to paste a compact verdict list back. The loop is asymmetric — you propose, they pick — so keep each card atomic and self-explanatory.

## Steps

1. **Resolve `$VAULT_PATH`** (`printf '%s' "$VAULT_PATH"`). It is served by the user's local web server, so the file is viewable in a browser. If unset/empty, stop and ask — do not guess a path.
2. **Build the review JSON** (schema below). One card per decision. Put images inline as base64 `data:` URIs — the file must be fully self-contained (no CDN, no external paths).
3. **Render**: read `references/template.html`, replace the contents of `<script type="application/json" id="reviewData">…</script>` with your JSON, write to `$VAULT_PATH/YYYY-MM-DD-<slug>-review.html`. Touch nothing else in the template.
4. **Hand off**: give the user the file path / URL. They review → 「피드백 복사」 → paste back to you → you apply and (if iterating) regenerate the next round.
5. **Commit only that one file** (`git -C "$VAULT_PATH" add <file> && git commit -m "review: <slug>"`) — never `git add .`; the dir holds other sessions' in-flight HTML. Pass the **보안 게이트** below before saving/committing.

## reviewData schema

```json
{
  "title": "책 변경 리뷰",
  "subtitle": "로컬 적용 완료, 발행 전 검토",
  "storageKey": "book-change-2026-06-05",   // UNIQUE per doc+round (localStorage namespace)
  "pills": ["확정","수정","보류"],            // optional; these 3 labels, in order
  "cards": [
    {
      "id": "term-rename",                   // stable unique id (localStorage key)
      "section": "용어",                      // optional; ≥2 distinct sections → sticky tabs auto
      "title": "신뢰 눈금 → 위임 등급",
      "loc": "4.5 제목 · 6장 ×3",            // optional: where it lives
      "why": "...어휘 근거 (inline HTML ok: <code>, <b>)",
      "before": "<code>신뢰 눈금</code> ...", // optional, rendered red
      "after":  "<code>위임 등급</code> ...", // optional, rendered green
      "images": [{"label":"후","src":"data:image/png;base64,..."}],  // optional; 2 → side-by-side
      "kind": "choice",                       // optional: offer A/B branches
      "options": [{"label":"A안","body":"..."},{"label":"B안","body":"..."}]
    }
  ]
}
```

- **before/after** are the workhorse. Omit both for an image-only or choice-only card.
- **kind:"choice"** adds clickable A/B options (radio) on top of the 3 pills — use when a change has branches; the picked option rides along in the exported feedback.
- **storageKey** must be unique per document and per round, or a new round inherits stale decisions.

## Notes

- Self-contained is non-negotiable: base64 every image, no `../` paths. The artifact must survive being copied anywhere.
- One card = one reversible decision. Split a sprawling change into atomic cards rather than one giant card.
- For a big batch, fan out section-by-section (subagents) → each returns its `cards[]` → merge into one JSON. Tabs keep it navigable.
- When a round is settled, the review file is disposable — old rounds can be deleted or compacted into one archive to cut noise.

## 보안 게이트 (저장·커밋 전 필수)

리뷰 파일은 `$VAULT_PATH`(비공개·로컬 서빙)에 저장되므로 카드 안의 개인·업무 콘텐츠 자체는 vault 엔트리와 같은 기준으로 OK다. 단 리뷰 도구는 **복사·전달되라고 만든 것**이라 누수 경계가 더 무르다 — 저장·커밋 전 셋을 본다.

1. **비밀값은 절대 임베드 금지.** API 키·토큰·비밀번호·인증 자격증명은 카드 텍스트에도 base64 이미지(스크린샷)에도 넣지 않는다 — 리뷰 파일은 돌아다닌다. 꼭 보여야 하면 마스킹(`sk-…REDACTED`).
2. **vault 밖으로 나갈 거면 PII 스크럽.** 이 파일을 비공개 vault 밖으로 보낼 가능성이 있으면 이메일·전화·주소·사내 호스트명을 먼저 가린다. vault 안에만 둘 거면 개인 콘텐츠는 OK(`$VAULT_PATH`는 비공개).
3. **스테이징 범위.** 만든 리뷰 파일 1개만 stage. `git add .`/`-A` 금지 — 다른 세션의 in-flight HTML 혼입 방지. (이 SKILL·template 자체는 공개 dotfiles에 있으니, 예시·기본값에 실제 비밀·PII를 절대 쓰지 않는다.)
