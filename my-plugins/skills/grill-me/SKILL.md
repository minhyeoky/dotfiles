---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when user wants to stress-test a plan, get grilled on their design, or mentions "grill me".
---

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time.

If a question can be answered by exploring the codebase, explore the codebase instead.

Likewise, if a question may already be settled in my saved notes, check `$VAULT_PATH` (set per-machine; skip this step when it is unset or empty) — grep it for the topic and read the matching note before asking. Treat what you find as dated prior context to confirm, not a settled fact.
