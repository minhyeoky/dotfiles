---
name: wrapup
description: Close out a work session by routing every uncommitted change to a terminal state — committed and pushed on the default branch, or opened as a PR — so nothing lingers. Trigger when the user says "wrapup", "wrap up", "작업 마무리", "세션 정리", "끝내자", or at the end of a session with a dirty working tree. Proactively suggest when the tree has accumulated changes across multiple concerns.
argument-hint: "[optional: paths or concern to gate behind a PR]"
---

# Wrapup Skill

Work is *done* only when it reaches a terminal state: committed and pushed on the
default branch, or merged via a PR. This skill drives a dirty working tree to that
state and leaves it clean, so no half-finished branch or uncommitted change lingers
into the next session.

The default branch is the home for routine work. A PR is reserved for changes the
user wants to gate behind their own review — the user is the gate, not every change.

## Steps

1. **Survey.** Run `git status`, note the current branch and ahead/behind counts.
   If the tree is clean, you are on the default branch, and nothing is unpushed →
   report "이미 정리됨, 할 일 없음" and stop.

2. **Detect remote visibility once** — `gh repo view --json visibility`.
   - PUBLIC: commit messages, PR text, and any content you add must be abstracted —
     no private, personal, or otherwise sensitive specifics. Generalize.
   - PRIVATE: detailed messages are fine.

3. **Group by concern.** Read the repo's `CLAUDE.md` for its commit-prefix and
   grouping conventions, then map each changed path to a concern. Never bundle
   unrelated concerns into one commit.

4. **Classify each group:**
   - *Cruft* — tracked-but-gitignored files, build artifacts that should not be
     tracked, local-only settings. Propose `git rm --cached` / discard / a
     `.gitignore` entry.
   - *Review-worthy code* — substantial app/source logic the user may want to gate.
     Flag as a PR candidate. This is the exception, not the default — only flag when
     the diff is real logic, or when the user named paths/concern in the arguments.
   - *Routine* — content, config, docs, generated artifacts, archive files.
     Goes straight to the default branch.

5. **Commit routine work automatically (no confirmation).** One atomic commit per
   concern, prefixed per `CLAUDE.md`, then push. After committing, run the project's
   post-work documentation rule from `CLAUDE.md` (update the relevant app docs,
   README, changelog).

6. **PR-gated work — only with confirmation.** Create a short-lived branch off the
   default branch, move just those changes onto it, commit, push, open the PR.
   After it merges, delete the branch (local and remote).

7. **Prune stale branches.** If the current branch's PR is already merged, switch to
   the default branch and delete the stale branch. Offer to prune other
   already-merged local branches (confirm scope before bulk-deleting).

8. **Report.** End state: tree clean, current branch, what was committed and pushed,
   any PRs opened. The session is done only when the tree is clean and nothing is
   left unpushed — except PRs that are intentionally awaiting review.

## Hard rules

- Default to the default branch; never auto-create a PR or delete a branch without
  confirmation.
- Honor remote visibility (step 2) in every message and any content you write.
- Hard-to-reverse actions (push to a shared branch, PR creation, branch deletion)
  are confirmed; routine commits to the default branch are not.
