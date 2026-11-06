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

1. `git status --short` is clean.
2. `git log --oneline <base>..<unit>` shows the expected commits.
3. `git diff --stat <base>..<unit>` touches only files inside the boundary.
4. Read the changed files. Run the unit's success check, plus the project's
   build/lint/test if one exists.
5. For non-trivial diffs, delegate a read-only `reviewer`.

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
git merge --ff-only <unit>
git worktree remove ../<repo>-<unit>
git branch -d <unit>
```

- If `--ff-only` fails because base moved, ask whether to rebase the unit in
  its worktree or merge normally. Do not choose silently.
- "Merge only": skip the last two commands.
- If a plan was used, tick its checkboxes and note the commit SHAs.
- Finish with `git log --oneline` for the merged commits.

## Escalation rules

- Raise issues to the user quickly; do not paper over them.
- If you are looping or stuck on the same problem, STOP and escalate.
- If a git/worktree command keeps failing, assume the sandbox (read-only
  mounts, denied paths, writes outside the repo). STOP and give the user the
  exact command to run. Do not keep retrying.
- Root-cause diagnosis stays in the parent; never hand a worker "go diagnose".
