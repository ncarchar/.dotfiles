---
name: bearings
description: Show what is in flight across every repo under ~/code (dirty trees, unpushed commits, extra worktrees, PLAN.md progress, RECON.md) plus recent pi session titles. Use when the user asks where they left off, what is in progress, or runs /bearings.
disable-model-invocation: true
---

# Bearings

Run `scripts/bearings.sh` (relative to this skill directory; absolute:
`~/.pi/agent/skills/bearings/scripts/bearings.sh`). Set `BEARINGS_ROOT` to scan
somewhere other than `~/code`, `BEARINGS_DAYS` for the session window (default 7).
Read-only.

Reply as a structured bulleted list, never run-on sentences. One block per repo,
newest session first, skipping quiet repos (give their count on the last line):

```
- **<repo>** (<branch>): <state in 3-6 words, e.g. 6 dirty, 1 unpushed>
  - Plans: <plan name> 10/42 done, 2 in progress
  - Worktrees: <n> (<ahead/dirty summary>)
  - Recent: <last session date>, <n> sessions
    - <session title>
    - <session title>
```

Omit lines that have nothing. Then end with:

- **Waiting on you:** finished worktrees to verify and merge, unpushed commits, dirty trees.
- **Next step:** one suggestion.

Stay under about 25 lines: at most 3 session titles per repo, and group
identical worktrees onto one line. Use only the script output.

Do not run other commands or open repos. If the user wants detail on one repo,
ask which, then look.
