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
5. **Commit only that one file** (`git -C "$VAULT_PATH" add <file> && git commit -m "review: <slug>"`) — never `git add .`; the dir holds other sessions' in-flight HTML. (The review artifact lives in the private `$VAULT_PATH`; its content is not the leak boundary — see 보안 게이트.)

## reviewData schema

```json
{
  "title": "변경 리뷰",
  "subtitle": "로컬 적용 완료, 발행 전 검토",
  "storageKey": "review-2026-01-01",         // UNIQUE per doc+round (localStorage namespace)
  "pills": ["확정","수정","보류"],            // optional; these 3 labels, in order
  "cards": [
    {
      "id": "card-1",                        // stable unique id (localStorage key)
      "section": "그룹 A",                    // optional; ≥2 distinct sections → sticky tabs auto
      "title": "옛 표현 → 새 표현",
      "loc": "3.2 제목 · 본문 2곳",           // optional: where it lives
      "why": "...근거 (inline HTML ok: <code>, <b>)",
      "before": "<code>옛 표현</code> ...",   // optional, rendered red
      "after":  "<code>새 표현</code> ...",   // optional, rendered green
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

## 보안 게이트 — 이 SKILL 편집 시 자가검열

누수 경계는 **생성되는 리뷰 산출물이 아니라 이 SKILL.md·template.html 자체**다. 산출물은 비공개 `$VAULT_PATH`(로컬, 외부 비노출)에 저장되므로 그 콘텐츠는 vault 엔트리와 같은 가정 아래 OK다. 반면 이 두 파일은 **공개 dotfiles 레포에 추적**되므로, 여기 적는 예시·기본값을 통해 사용자가 실제로 다루는 게 무엇인지(프로젝트·주제·도메인)가 영구 공개로 새어 나갈 수 있다. 이 파일을 고칠 때 점검한다.

- **예시·기본값은 중립 placeholder만.** title·storageKey·section·카드 샘플에 실제 프로젝트·주제·고유명을 드러내지 않는다(책 제목, 운세/사주 앱, 금액·종목, 지역, 관계 등). `"변경 리뷰"`·`"옛 표현 → 새 표현"`·`"A안/B안"`처럼 도메인 없는 generic으로.
- **template 기본 JSON·주석에 실제 비밀·PII·개인 경로 금지.**
- 스킬 파일만 stage(`git add .` 금지).
