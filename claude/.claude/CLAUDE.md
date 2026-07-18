# CLAUDE.md

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

## 5. Model Selection — match tier to task KIND

**Judgment stays at the main-loop tier; implementation delegates DOWN to the cheapest tier that suffices, verified back in the loop.**

Pick the tier by the KIND of work, not a fixed default:
- **Judgment** (design, review, synthesis, audit) → the main-loop tier (the top model you're running). This is the bottleneck — spend here.
- **Real implementation** (coding once the design is settled) → Sonnet subagent. The top model is rarely needed to implement.
- **Mechanical/trivial edits** (rename, format, rote changes) → Haiku subagent.

Rules:
- In `agent()` calls, omit `model` to inherit the session model by default. Set an explicit tier only to delegate DOWN (Sonnet/Haiku) for implementation, or UP (Opus) for multi-source synthesis / adversarial judgment when the session model is weaker.
- Make each subagent instruction self-contained — executable without the main-loop context.
- Verify and commit results in the main loop; keep design/audit/analysis there.
- **Stop when review falls behind generation** — your review speed is the ceiling on how much delegation you can absorb. Batch-review large changes async.
- Never delegate or upgrade "just in case," and never route a simple search/read/transform agent through a bigger model than it needs.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.
