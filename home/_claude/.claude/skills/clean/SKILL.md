---
name: clean
description: Run a ponytail-guided repo audit, present a numbered change list for user approval, then execute approved tasks in parallel using subagents. Use when the user wants to audit and clean up the codebase.
disable-model-invocation: true
context: fork
agent: general-purpose
background: false
allowed-tools:
    - Bash(git status *)
    - Bash(git diff *)
    - Bash(git add *)
    - Bash(git commit *)
    - Skill(ponytail:ponytail-audit)
---

# audit

You are running as a sonnet-class agent. The user's configured sonnet model is `deepseek/deepseek-v4-pro-0813`.

## Phase 1: Audit

Run `/ponytail-audit` to audit the repo for over-engineering. Additional scope or focus from the user: $ARGUMENTS

Instruct ponytail to return its findings as a numbered and lettered list in exactly this format:

#1 <Section Title>

- 1A: <specific change>
- 1B: <specific change>

#2 <Section Title>

- 2A: <specific change>

If "$ARGUMENTS" is empty, ask the user what area or concern to focus the audit on before proceeding. Prefer asking over exploring the repo blindly.

## Phase 2: User Approval

Present the full list to the user. For each item, the user may:

- Approve it (proceed)
- Reject it (skip entirely)
- Comment on it (revise the task description to reflect their input before dispatching)

Wait for the user to respond to all items before proceeding. Do not assume approval. Do not proceed until every item has an explicit disposition.

## Phase 3: Parallel Dispatch

**You must never perform any code changes yourself in this phase. In this phase, all changes without exception, must be delegated to haiku subagents. If you find yourself editing a file directly, stop and dispatch a subagent instead.**

Before dispatching, determine which tasks are likely to touch overlapping files or shared modules. Group those into a dependency order and serialize them. Tasks that touch independent areas can run in parallel. State your parallelization plan to the user before dispatching so they can object.

For each approved or commented item, spawn a haiku subagent (`deepseek/deepseek-v4-flash-0731`) with a fully self-contained task prompt. Each subagent prompt must include all of the following:

- **Task ID and title** (e.g. "Task 1A: Remove redundant cache wrapper in src/cache/wrapper.ts")
- **Exact file paths** to read and modify, resolved before dispatch. Do not send a subagent to find its own files.
- **A precise, literal description of the change**: what to delete, what to replace it with, and what the result should look like. Do not use vague instructions like "simplify" or "clean up". Say exactly which function, class, import, or block is the target and what the end state must be.
- **The user's comment verbatim** if they provided one, plus your interpretation of how it changes the task.
- **Ponytail ruleset context**: write only what the task needs, reuse before rewriting, stdlib before dependencies, minimum that works.
- **Hard constraints**:
    - Make the smallest correct change and nothing else.
    - Do not run tests.
    - Do not commit.
    - Do not touch any file not listed in this prompt.
    - Do not introduce new dependencies.
    - Do not refactor anything outside the stated scope, even if it looks like it needs it.

After dispatching all subagents, **you must block and wait for every subagent to report completion before proceeding to Phase 4**. Do not begin verification until all dispatched subagents have returned a result, whether success or failure.

## Phase 4: Verification

When **all** subagents have completed, perform verification in two passes:

Per-task inspection: For each completed task, read the diff and confirm:

- The change matches the approved task description
- No unrelated files were touched
- No new dependencies were introduced without approval
- The change does not obviously break call sites or imports

Final verification: Attempt to compile or build the project using whatever build tool is present (tsc, mvn, gradle, npm run build, cargo build, etc.). If compilation fails, identify which task introduced the breakage, fix it yourself (do not re-dispatch to haiku), and note the fix in your summary.

## Phase 5: Summary

Report to the user:

- Which tasks were completed successfully
- Which tasks had issues and how they were resolved
- Any tasks that were skipped (rejected or serialized-and-pending)
- The final build/compile status

