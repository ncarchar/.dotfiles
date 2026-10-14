---
name: plan
description: Create a gitignored implementation plan under __<slug>/PLAN.md, get the plan approved, then implement it while tracking progress via inline checkboxes and escalating problems promptly.
disable-model-invocation: true
argument-hint: "[slug]"
allowed-tools:
    - Skill(commit)
    - Bash(mkdir *)
    - Bash(git status *)
    - Bash(git diff *)
    - Bash(git rev-parse *)
---

# Plan

You run a plan-tracked implementation workflow. On `/plan <slug>` you set up a
gitignored plan directory, write an implementation plan, STOP for approval, then
(after approval) implement while keeping the plan's status current.

## Phase 0 — Gitignore guard (do this first)

1. If there is no git repo (`.git` is absent), stop and ask the user before
   creating anything.
2. Read `.gitignore` and check for a line `/__*/`.
   - Present: continue to Phase 1.
   - Missing: append `/__*/` on its own line, then commit ONLY that `.gitignore`
     change using the `commit` skill (run `/commit`). Do not bundle other changes
     into this commit.

## Phase 1 — Create the directory and plan

1. Determine the slug. Use the `<slug>` argument if given; otherwise infer a short
   one from the task (lowercase, hyphens, no spaces, e.g. `add-oauth`).
2. Create `__<slug>/`.
3. Write `__<slug>/PLAN.md` using the template and writing rules below.

### PLAN.md template

```markdown
# <Title>

<One-sentence goal: what is being built and why.>

Status legend: `[ ]` not started · `[~]` in progress · `[x]` complete

## Context

<What the plan depends on: reference repos, existing code, hard requirements,
and the current state. Compare two systems or map a shared field across apps
with a table when it is clearer than prose.>

## Plan

- [ ] <Stage 1> — one-line summary of what changes
  - <concrete sub-step: exact file, value, or command>
  - <acceptance criterion / how you know it is done>
- [ ] <Stage 2> ...

## Open questions

- [ ] <unresolved unknown the plan depends on>

## Risks

- <what could break, and the escape hatch>
```

### Writing rules

Write every plan item so it can be checked off without re-deriving the context:

- Name the exact files to touch.
- Quote exact values, endpoints, and URLs.
- Put commands in fenced code blocks.
- State the acceptance criterion for each stage.
- Give a revert path when the change is risky; note anything that must NOT be
  torn down until explicitly told.
- Record gitignored scratch paths (e.g. `__deployment/`) when a stage relies on
  scripts that live outside the repo.

Split stages by size and risk: frontend-only vs backend, or a small safe stage
before a large risky one.

### Status conventions

Track progress two ways; pick by the shape of the work:

- **Inline checkboxes** (default, for implementation work): each plan item is a
  `[ ]` line. Flip to `[~]` while working and `[x]` when done, and append `- `
  note sub-bullets under in-progress/done items recording: what was actually
  implemented, any deviation from the plan, and any issues hit.
- **Status table** (for strictly sequential operational work, e.g. a deployment):
  add a `| Step | Status | Notes |` table near the top and update it as each
  stage completes.

While implementing, record every gotcha under the relevant item or in a
`## Gotchas` section: one bullet with the fix and the commit SHA. This is the
highest-value part of the plan for future readers.

Put scratch files (temp scripts, sample output) inside `__<slug>/`, not in the
repo root.

## Phase 2 — STOP and get approval

After Phase 0 and Phase 1, show the plan (paste `PLAN.md`) and STOP. Do not
implement anything until the user approves or edits it. This is a hard gate.

## Phase 3 — Implement

After explicit approval, work through the plan in order. After each item, update
its checkbox and note lines. Only check in with the user when an issue needs
their decision or they explicitly asked to stop at each stage; otherwise keep
going through the list.

## Escalation rules

- Raise issues to the user quickly; do not silently work around or paper over them.
- If you are looping or stuck on the same problem, STOP and escalate instead of retrying.
- If a command keeps failing, assume the sandbox may be the cause (read-only
  mounts, `/dev/null` stubs over dotfiles, denied paths). STOP, report it, and
  give the user the exact command to run. They will run it and give you the
  result. Do not keep retrying.
- If a stage needs a decision the plan does not cover, ask instead of guessing.
