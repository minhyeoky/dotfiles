---
name: retro
description: "Retrospective on a coding session: re-read the session's transcript, find where the agent struggled, and propose fixes to the agent's environment (pointers, checks, review rules, steering-file cuts, tooling, information access) so the next run goes better."
disable-model-invocation: true
argument-hint: "[session-id or description]"
license: MIT
---

The user has asked for a **retrospective**. You are suggesting improvements to the agent's **environment** — the files, checks, tools and steering every future session runs in — based on the defects one session exposed. You do not fix the code the session produced.

## Steps

1. **Pick the session.** Use the one given in `$ARGUMENTS`; if empty, the current one (`$CLAUDE_CODE_SESSION_ID`). Transcripts live at `~/.claude/projects/<slug>/<session-id>.jsonl`, where the slug is the session's working directory with `/` and `.` replaced by `-` (a worktree has its own slug); delegated agents' transcripts sit under `<session-id>/subagents/`, and struggles inside them are invisible from the main file. A session named by description is found with `grep -l` across `~/.claude/projects/*/*.jsonl`. Read the transcript rather than relying on recall: by the end of a session the struggles from the middle have faded, and recall drifts toward generic advice. Transcripts run to megabytes — filter with `jq`/`grep` for tool calls, tool results and errors instead of reading them whole.

2. **Read the environment the session ran in.** The repo's steering files (`CLAUDE.md`/`AGENTS.md`, global and repo), the files its reviewer reads, its check commands (`package.json`/build-tool `lint`/`check` scripts, pre-commit and pre-push hooks, CI workflows). A check that already exists but sits unwired or silently broken is the finding — not a reinvention.

3. **Find the struggle moments.** Wrong turns, long searches, retries, errors, a mistake that reached review or the user, an expensive tool call, information the agent asked for and could not get. Each candidate must cite one of these moments (a quoted line or tool call from the transcript). A setup defect found in step 2 (a missing guardrail, an oversized steering file) also cites the `file:line` it lives in, and the moment where it made this session worse. A candidate you cannot trace to a moment is discarded, however sensible it sounds.

4. **Classify each candidate into one category** — the category decides where the fix goes:

   - **Navigation**: the agent took long to find a file or fact, or tripped on a hidden dependency between files. Fix: a **navigation pointer** from a file the agent already reads.
   - **Automated checks**: the agent made a mistake a deterministic check could have caught — lint, types, tests, a filesystem linter, a hook. A repo with no **guardrail** at all (no pre-commit hook and no CI job running its lint/typecheck/test command) is itself a finding. Fix: wire or add the check.
   - **Review rules**: the reviewer missed a mistake. Classify the violation first. A **mechanical** one (a fixed syntactic pattern, a banned API, an import shape, a file-location rule) gets a deterministic check, full stop — a custom rule in the repo's linter, a hook, or a CI job, whichever the repo's existing guardrail makes cheapest. Only genuine **judgement calls** (cross-file consistency, "matches the surrounding style") become prose, in whatever file the repo's reviewer reads; if there is none, propose creating one and name its path. A check can fail; a sentence cannot. A reviewer rule that misfired is a candidate to remove or clarify.
   - **Steering size**: an always-loaded steering file — in the repo or the user's global scope — is large and carries rules that belong in review rules or a check. Fix: move them out.
   - **No-ops**: a steering line that restates what the agent would do anyway. Fix: delete it. A steering line the agent violated is not a no-op — it is evidence for a check or a review rule. One session is weak evidence — mark these as candidates for deletion (remove the line and watch whether a later session behaves differently), not verdicts.
   - **Tool economy**: a tool call that was expensive for what it returned, or custom tooling (CLI, MCP) that is token-inefficient. Fix: streamline or replace the tool.
   - **Information access**: a crucial piece of information was out of the agent's reach. Fix: widen read access — tee dev-server logs to a file, read-only access to a third-party service.

5. **Report the candidates, most severe first.** Severity is the cost of the defect recurring, not how loud the moment was: a quiet, expensive mistake outranks a loud, cheap one. For each candidate give: the category, the cited moment, the proposed fix and the file it touches. Say so when the session was smooth and there is little to report — do not fill categories to look thorough.

Whether a candidate is then applied, and through what gate, is decided by the repo's own rules and the user, not by this skill.

## Reference

### Implementation vs review

Work goes through two stages. The implementation agent carries the most **context pressure**: it explores, writes code and debugs failures. The review agent receives a diff and needs neither exploration nor debugging. So a new rule goes to the reviewer, where there is room to apply it.

### Where fixes land

- Always-loaded steering files (`CLAUDE.md`/`AGENTS.md`): pushed into every session's context whether relevant or not, so every line there taxes every session.
- Docs: reference files reached through pointers. Look for an existing doc before writing a new one.
- Skills: for user-invoked procedures, or for docs whose description should sit in the agent's context.
