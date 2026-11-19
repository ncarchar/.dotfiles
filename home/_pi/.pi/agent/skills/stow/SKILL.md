---
name: stow
description: Wrap up a nearly finished session. File durable knowledge in the repo's AGENTS.md (kept slim) and bring PLAN.md and similar tracking files up to date so the next session can resume cold. Use when the user runs /stow, or asks to wrap up or save state.
disable-model-invocation: true
---

# Stow

The session is almost done: leave the repo in a state a fresh session can pick
up cold. Two jobs:

1. Move durable knowledge into the project's `AGENTS.md` (repo root), keeping
   it short and accurate.
2. Bring tracking files up to date (see "Tracking files").

Create no files beyond `AGENTS.md` (when absent) and do not commit.

## What belongs

- Commands to build, test, or run that are not obvious from the manifest.
- Gotchas: a sharp edge, workaround, or recurring mistake found this session.
- Conventions and decisions that should outlive the session, including options ruled out.
- Stated user preferences for this project.

## What does not

- Anything the code, README, or config already says: link to it in one line instead.
- Values that go stale: versions, dates, line numbers, counts, ports, URLs that churn.
- Task progress and next steps: those live in `__<slug>/PLAN.md` (see "Tracking files").
- Anything you are not sure is true or lasting.

## Tracking files

Find them: `__*/PLAN.md`, `__*/RECON.md`, and any TODO/notes file the session
touched. Update only the ones this session's work relates to.

- Tick `- [x]` for work actually finished and verified this session; mark
  `- [~]` for work started but not done. Never tick what you did not verify.
- Add items the session discovered but did not do, and drop or reword items it
  showed to be wrong or obsolete.
- For each `[~]` item, add a one-line note of where it stopped and the next step.
- Keep the file's existing format and wording; do not restructure it.
- Say if the work done has no PLAN.md; do not invent one unless the user asks.

## Steps

1. Read `AGENTS.md` in full (create it with one `# <repo>` heading if absent).
2. List candidate findings from the session. Drop those excluded above.
3. For each, in the file already: duplicate, superseded, or new. Rewrite or
   merge the existing line; append only when it is genuinely new. Delete lines
   the session showed to be wrong.
4. Size gate: the file must stay under about 60 lines. If an addition would
   cross it, prune the weakest existing lines first (stale, derivable, vague).
   Prefer one terse bullet per fact, under a short heading.
5. Update tracking files per the section above.
6. Report one line per change (`added`, `rewritten`, `removed`, `ticked`),
   anything you skipped and why, and uncommitted work left behind. Leave the
   diff for the user to review and `/commit`.
