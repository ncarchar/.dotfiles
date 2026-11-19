---
name: dispatch
description: Run planned work through worker agents in git worktrees, verify the result yourself, ask before merging, then merge locally and clean up. Use when the user asks to dispatch, delegate, or farm out implementation work.
disable-model-invocation: true
argument-hint: "[slug | path to PLAN.md]"
allowed-tools:
    - Skill(commit)
    - Bash(git worktree *)
    - Bash(git merge *)
    - Bash(git branch *)
    - Bash(git status *)
    - Bash(git log *)
    - Bash(git diff *)
    - Bash(git rev-parse *)
    - Bash(~/.pi/agent/skills/dispatch/scripts/*)
---

# Dispatch

Delegate bounded units of work to `worker` agents, each in its own git
worktree. Verify the result yourself, ask the user, then merge and clean up.
Never push.

## Phase 1 - Preflight

1. If `.git` is absent, stop and ask the user.
2. Record the base branch: `git rev-parse --abbrev-ref HEAD`.
3. Run `git status --short`. Stop and ask if tracked files have uncommitted
   changes. Ignore untracked sandbox dotfile stubs (`.bashrc`, `.env`, ...).

## Phase 2 - Scope

1. Take the work from `__<slug>/PLAN.md` (see the `plan` skill) if an
   argument or an obvious plan exists, otherwise from the conversation.
2. Split it into units that touch disjoint files. One worktree per unit.
   If units overlap, run them one after another, or ask the user.
3. For each unit write down: objective, edit boundary (exact files), and the
   one check that proves it works.

## Phase 3 - Worktree and dispatch

Per unit, with a short lowercase-hyphen `<unit>` name:

```
git worktree add -b <unit> ../<repo>-<unit> <base>
```

Then call `acp_delegate` with `agent: worker`, `cwd: ../<repo>-<unit>`
(absolute path), and a self-contained task that states:

- the objective and the edit boundary;
- the success check;
- "commit on the current branch with a conventional commit message";
- "do not merge, push, switch branches, or touch files outside the boundary".

One unit: `async: false`. Several units: `async: true`, then one
`acp_delegate_wait` per runId (never poll). Do not hard-cap a worker; set a
`timeoutMinutes`.

## Phase 4 - Verify (parent does this, never the worker)

A worker's exit status and self-report prove nothing. A delegate can exit
non-zero after finishing the work (extension crash at shutdown), or exit 0
without doing it. Check git state in each worktree:

1. Run the mechanical checks from the main checkout (clean worktree, expected
   commits, diff inside the boundary; boundary entries are files or `dir/`):

   ```
   ~/.pi/agent/skills/dispatch/scripts/verify.sh <base> <unit> <boundary>...
   ```

   Exit 1 means fail; treat the printed `FAIL:` lines as the evidence.
2. Read the changed files. Run the unit's success check, plus the project's
   build/lint/test if one exists.
3. For non-trivial diffs, delegate a read-only `reviewer`.

If verification fails: report it with the evidence. Allow one retry (resume
the run with `resumeFrom`, or re-dispatch with the exact defect). A second
failure goes to the user. Leave the worktree and branch in place.

## Phase 5 - Gate

STOP. Summarize each unit (commits, files, checks run) and call
`ask_user_question` with: "Merge and clean up", "Merge only", "Leave it".
Do not merge without an answer.

## Phase 6 - Merge and clean up

In the main checkout, per verified unit:

```
~/.pi/agent/skills/dispatch/scripts/merge.sh <base> <unit> [--keep]
```

It runs `git merge --ff-only`, removes the worktree, and deletes the branch.

- Exit 2 means the base moved (or is not checked out): ask whether to rebase
  the unit in its worktree or merge normally. Do not choose silently.
- "Merge only": pass `--keep`.
- If a plan was used, tick its checkboxes and note the commit SHAs.

## Escalation rules

- Raise issues to the user quickly; do not paper over them.
- If you are looping or stuck on the same problem, STOP and escalate.
- If a git/worktree command keeps failing, assume the sandbox (read-only
  mounts, denied paths, writes outside the repo). STOP and give the user the
  exact command to run. Do not keep retrying.
- Root-cause diagnosis stays in the parent; never hand a worker "go diagnose".
