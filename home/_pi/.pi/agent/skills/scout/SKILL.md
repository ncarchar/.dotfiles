---
name: scout
description: Read-only recon of a repo or question, saved to a gitignored __<slug>/RECON.md that /plan reads. Use for "run recon", "look into X before we plan", or /scout. Can scout several repos in parallel.
disable-model-invocation: true
argument-hint: "[slug] [question or repo paths]"
allowed-tools:
    - Bash(mkdir *)
    - Bash(git status *)
    - Bash(git rev-parse *)
---

# Scout

Recon that changes no code and leaves a durable report, so planning and
dispatch start from facts instead of re-exploring.

## Steps

1. Ensure `.gitignore` has `__*/` (Phase 0 of the `plan` skill; commit that line
   alone with `/commit` if you add it).
2. Pick a slug (argument, or short lowercase-hyphen from the task) and create
   `__<slug>/` in each repo being scouted.
3. Delegate one `researcher` per repo with `acp_delegate`, `cwd` set to the repo.
   One repo: `async: false`. Several: `async: true`, then one `acp_delegate_wait`
   per runId. The task must state: the question, "read-only, change nothing",
   and ask for the report sections below, under 60 lines, citing `path:line`.
4. Write each result to `__<slug>/RECON.md` yourself (the delegate is read-only),
   trimmed to the template. Check any claim the plan will depend on.
5. Reply with a three-line summary and the path. Offer `/plan <slug>`.

## RECON.md template

```markdown
# Recon: <question or repo>

## Layout
<stack, entry points, how the relevant code is organised>

## Commands
<build, test, lint, run; only those verified to exist>

## Relevant code
<files and symbols tied to the question, with path:line>

## Conventions and risks
<patterns to follow, traps, things that look relevant but are not>

## Unknowns
<what could not be determined>
```

Keep it facts only: no plan, no recommendations beyond the unknowns.
