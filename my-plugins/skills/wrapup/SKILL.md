---
name: wrapup
description: Close out a work session by routing every open loop — uncommitted code AND uncaptured context — to a durable home before the session's working memory evaporates. Code goes to git (committed/pushed on the default branch, or a PR); decisions go to memory; an unfinished thread goes to a handoff or an explicit park. Trigger when the user says "wrapup", "wrap up", "작업 마무리", "세션 정리", "끝내자", or at the end of a session with a dirty tree or unrecorded decisions. Proactively suggest when state has accumulated across multiple concerns.
argument-hint: "[optional: paths or concern to gate behind a PR]"
---

# Wrapup Skill

## Why this exists

A session holds its real state in volatile working memory. When the session ends,
that context evaporates — and with it, the cheap answer to *why this change*, *what
was decided against*, *what is half-done*. A session leaves two debts:

- **Code debt** — uncommitted changes in the tree.
- **Knowledge debt** — the reasoning, decisions, and loose threads that live only in
  the conversation.

The recovery cost of both **rises monotonically as context decays**. The next session
pays it at a higher rate, with less context, often by asking you to reconstruct what
you already knew. So the entire job of wrapup is: **while context is still cheap (now),
route every open loop to a durable home.** Anything left implicit is a debt deferred to
a worse moment.

Wrapup does not reimplement those homes — it dispatches to them. Git is one home, not
the whole job.

## The engine: survey first, propose, then execute

Don't jump to writing. The flow is always: **survey → propose → confirm intent → execute.**

**1. What *kind* of state is it?** → picks the durable home.

| State | Durable home |
|---|---|
| Working code / config / content | git — commit + push (or PR) |
| A **rule** Claude must follow ("always X", "never Y") | `CLAUDE.md` — or `.claude/rules/` with `paths:` if it only applies to some files |
| A **fact**: state, decision, rationale, external reference | `memory/` (see the memory system) |
| A rule that must hold *every* time, no exceptions | a hook or permission — CLAUDE.md is a request, not a guarantee |
| An unfinished thread a successor must resume | a `handoff` document |
| Deferred work you are choosing not to do now | an **explicit** park — TODO, issue, or a noted line. Never silent. |

**2. Who must confirm before you write anything?** → always the user.

Every write action — commits, memory writes, handoff docs, PR creation, branch deletion —
requires the user to confirm intent first. The survey phase is read-only. After surveying,
present a proposed routing plan and ask. Only execute after the user approves.

The only exception: purely mechanical read operations (git status, log, diff) that
produce no side effects are always safe to run without asking.

## memory vs CLAUDE.md — picking the home

The axis is **instruction vs fact**, and **who maintains it**. It is *not* stability, and
it is *not* app-boundness. "It rarely changes" and "it belongs to one app" are both true
of things in either home, so neither tells you where to put anything.

- **CLAUDE.md** = rules you write for Claude to obey. The root one loads **in full, every
  session** — its cost is real and permanent.
- **memory/** = facts Claude records and reads back on demand. Topic files cost **0 tokens
  at startup**; only `MEMORY.md` (the index) is always loaded, capped at 200 lines / 25KB —
  **past the cap it is silently dropped**, so the index is the only thing worth budgeting.

Consequences that are easy to get backwards:

- **Never move content into CLAUDE.md to "save context."** It inverts the cost — you move
  something free into something billed every session. Volume in `memory/` is not a problem
  worth solving; a bloated *index* is.
- **Duplication is the real failure, not volume.** When a rule lives in both homes they
  drift, and contradictory rules make Claude pick one arbitrarily. The verb is **delete one
  side**, never "move." Before writing a rule to either home, grep the other for it.
- **memory is machine-local and not in git** — no history, no diff, no review, lost on a new
  machine. Anything that needs versioning, sharing, or an audit trail belongs in the repo.
  Decision *logs* especially: git already remembers why.
- **Keep derivable content out of CLAUDE.md** — directory layouts, port tables, app
  inventories, dependency lists. Claude can read those from the tree, and they rot fastest.
  CLAUDE.md earns its cost with pitfalls, rationale, and conventions that differ from
  defaults.

## Writing to memory: supersede, verify, and leave guards alone

Memory rots by **appending without invalidating**, not by growing. Three rules:

- **Supersede in the same edit.** When a new fact contradicts one already in the file,
  amend or delete the old line — do not append beside it. Two present-tense claims that
  disagree is the defect; file size is only its shadow. If a file has become an append-only
  session log, that is the signal to rewrite it, not to split it.
- **Verify checkable claims before writing.** Counts, paths, command names, URLs, and
  ports are cheap to check against the tree and are the first things to go stale. An
  unverified number is worse than no number — it will be trusted later. Better still,
  record *how to derive* a moving number instead of the number: a count that changes daily
  is a stale-generator no matter how carefully you update it today.
- **Check against `git show HEAD:<path>`, not the working tree.** A dirty tree may be
  someone else's work in progress, and judging a memory "stale" against uncommitted edits
  gets the verdict exactly backwards. If HEAD and the working tree disagree, that
  disagreement is the finding — report it and hold the verdict.
- **Never judge a negative guard by its age.** A guard like "don't propose X again" works
  precisely by nothing happening, so it looks abandoned when it is doing its job. Staleness
  heuristics invert on these. Same for a file that documents an *unresolved* gap: code
  disagreeing with it can be the very thing it records.

## The bar for "done"

Not "tree is clean." That is necessary, not sufficient. The real test:

> **A zero-context successor could resume or verify the work without asking you.**

Every change committed/pushed/PR'd; every decision worth keeping in memory; every
unfinished thread either resume-ready (handoff) or explicitly parked. **No open loop
left implicit.**

## Working it

1. **Survey both debts.** `git status` + ahead/behind for code debt. Scan the
   conversation for knowledge debt — decisions made, things ruled out, threads left
   hanging. If both are empty (clean tree, on default branch, nothing unpushed, nothing
   undecided) → "이미 정리됨, 할 일 없음" and stop.

2. **Detect remote visibility once** — `gh repo view --json visibility`. PUBLIC →
   every commit message, PR body, and written artifact must be abstracted: no private,
   personal, or sensitive specifics. PRIVATE → detail is fine. This gate applies to
   memory and handoff content too, not just git.

3. **Map out the open loops.** Group code by concern (read the repo's `CLAUDE.md` for
   commit-prefix and grouping conventions); never bundle unrelated concerns. Note which
   files would go in which commit, which decisions are memory-worthy, and whether any
   thread needs a handoff doc.

4. **Propose and confirm before writing anything.** Present the full routing plan to the
   user — what would go into each commit, what would land in memory, what would become a
   handoff, what would be parked. Ask which parts the user actually wants done and in what
   order. If it's a long list, ask one category at a time. Do **not** execute any write
   until the user confirms.

5. **Execute what was approved.** After each confirmed scope: commit atomically per
   concern + push; write memory entries; produce handoff doc if needed. After committing,
   run the project's post-work documentation rule from `CLAUDE.md`; fold any doc changes
   into the same concern's commit. For review-worthy logic, branch off, move changes,
   open the PR.

6. **Report against the bar.** State the end position: tree status, branch, what was
   committed/pushed, PRs opened, what landed in memory/handoff, what was parked and
   where. Done only when no open loop is implicit — except PRs intentionally awaiting
   review.

## Hard rules

- Every write action needs user confirmation first — even routine commits. The user's intent, not reversibility, is the gate.
- Routine commits go to the default branch (no PR); a PR is for changes the user explicitly wants gated. Both still require step 4 confirmation.
- Honour remote visibility (step 2) in **every** written artifact — commit, PR, memory,
  handoff alike.
- Parking is allowed; *silent* parking is not. An unfinished thread must leave a visible
  marker, or it isn't done.
- Route by instruction-vs-fact, never by "how much context it costs" — and never write the
  same rule to both homes. If it is already in the other one, delete a side instead.
