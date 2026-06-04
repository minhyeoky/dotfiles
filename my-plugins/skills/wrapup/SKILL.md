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

## The engine: two questions decide every routing

Don't memorise a taxonomy. Run each open loop through two questions and the routing
falls out.

**1. What *kind* of state is it?** → picks the durable home.

| State | Durable home |
|---|---|
| Working code / config / content | git — commit + push (or PR) |
| A fact, decision, or rationale worth keeping | `memory/` (see the memory system) |
| An unfinished thread a successor must resume | a `handoff` document |
| Deferred work you are choosing not to do now | an **explicit** park — TODO, issue, or a noted line. Never silent. |

**2. Who must be the gate, and how reversible is it?** → picks autonomy.

- Reversible *and* you are the legitimate gate (routine commits, memory writes,
  handoff docs) → **act, no confirmation.**
- Irreversible *or* the user is the gate (PR creation, pushing logic the user wants to
  review, any branch deletion) → **confirm first.**

The old cruft / routine / review-worthy split is just this engine applied to code:
cruft is reversible cleanup you own, routine is reversible default-branch work you own,
review-worthy is logic where the *user* is the gate. You no longer memorise the split —
you derive it.

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

3. **Route each loop through the engine.** Group code by concern (read the repo's
   `CLAUDE.md` for commit-prefix and grouping conventions); never bundle unrelated
   concerns. If one file mixes two concerns, split with `git add -p`. Send each
   knowledge loop to memory, handoff, or an explicit park.

4. **Execute the autonomous routes (no confirmation):** one atomic commit per concern,
   prefixed per `CLAUDE.md`, then push; memory writes; handoff doc if a thread needs
   resuming. After committing, run the project's post-work documentation rule from
   `CLAUDE.md`; fold any doc changes it produces into the *same* concern's commit so
   wrapup doesn't leave its own dirt.

5. **Execute the gated routes (with confirmation):** for review-worthy logic, branch
   off the default branch, move just those changes over, commit, push, open the PR. For
   stale-branch pruning, confirm scope before deleting anything.

6. **Report against the bar.** State the end position: tree status, branch, what was
   committed/pushed, PRs opened, what landed in memory/handoff, what was parked and
   where. Done only when no open loop is implicit — except PRs intentionally awaiting
   review.

## Hard rules

- Default branch is the home for routine work; a PR is reserved for changes the **user**
  wants to gate. The user is the gate, not every change.
- Never auto-create a PR, delete a branch, or push user-gated logic without confirmation.
- Honour remote visibility (step 2) in **every** written artifact — commit, PR, memory,
  handoff alike.
- Parking is allowed; *silent* parking is not. An unfinished thread must leave a visible
  marker, or it isn't done.
