# environment

- `$COV=1` = work machine: WSL (Debian), Nix + Home Manager.
- `$COV` unset = personal machine: NixOS.

# pi-sandbox dotfile stubs

`pi-sandbox` runs every bash command in an OS-level sandbox (bubblewrap). It
mounts `/dev/null` over sensitive dotfiles (`.gitconfig`, `.bashrc`,
`.bash_profile`, `.zshrc`, `.zprofile`, `.profile`, `.ripgreprc`, `.mcp.json`)
and over `denyWrite` patterns from `~/.pi/agent/sandbox.json` such as `.env`.
A name that does not exist yet becomes a mount point: a char device (`c`),
`crw-rw-rw-`, device `1,3`, size 0, owner `nobody:nogroup` (see `ls -la`).

These hold no data and are not repo files, secrets, or leaked host dotfiles.
Do not read, edit, or commit them, and do not flag them as leaks. Ignore them.

# file reading

Read files with the `read` tool only; never `sed`, `awk`, `perl`, or `cut`.
For partial views, `offset` is the 1-based first line and `limit` the line
count. (`read` never triggers an approval prompt; `sed -i` mutates in place.)

- `sed -n '101,170p' f` → `read path=f offset=101 limit=70`
- `sed -n '1,50p' f` → `read path=f limit=50`
- `cat f` → `read path=f`

# tools

Use `rg`, not `grep`, for searching. Available on both machines:

`git gh rg find jq make just cmake node pnpm tsc python3 cargo clang mvn curl wget parallel tmux awscli2 direnv unzip zip`

# redaction

Email addresses, phone numbers, social security numbers, credit card
numbers, and other secrets may be automatically redacted before they reach
you, appearing as placeholders such as `[REDACTED]` or similar. This is
intended behavior. Do not treat a redacted value as an error or a loss of
context; proceed with the information you have and do not try to recover or
reconstruct the original value.

# response style

- Write code, comments, docs, and replies in English;
- Replies should be succinct and easy to understand.
- No em dashes, en dashes, or emojis, anywhere.
- Read only what the task needs; ask before a large or read-heavy step.

# code style

- Self-documenting code; comment only what is not obvious.
- Always use braces in `if`/`for` blocks where the language supports them.
- Indent with 4 spaces.

# sub-agent dispatch (herdr + pi-dispatch)

This machine runs a master + sandboxed-sub-agent pattern. This
section applies to both roles, because master and children share this `~/.pi`.
The full model, including verified findings and known limits, is
`/home/cvhew/.dotfiles/HERDR-ORCHESTRATION.md`. Read it before extending the tooling.

## As the master (dispatching work)

- Stay sandboxed. Dispatch goes over the herdr socket to the already-running
  herdr server, never as your own child process, so `--die-with-parent` does not
  apply. You need no unsandboxed powers to orchestrate.
- Run one sub-agent with `~/.scripts/pi-dispatch <task...>` (or stdin). It returns
  the child's answer; the worker runs in its own workspace (space) and is left
  open by default. `pi-dispatch --cwd DIR` puts the worker in another project
  directory; `--branch NAME` creates a git worktree plus branch, the worker commits
  there, the checkout is removed on completion, and the branch is kept.
  `pi-dispatch --close` reaps the workspace (and checkout) on completion;
  `pi-dispatch --reap` closes workspaces, worktrees, and legacy tabs left by
  dispatches that died mid-run.

## As a dispatched child (doing the work)

- Your task is at `<run>/brief.md` (the absolute path is in your prompt). Do the
  work, write only your final answer to `<run>/result.md`, then reply exactly
  `DONE`. The first line of `result.md` must be exactly `status: done` or
  `status: failed`. The master detects completion via herdr state (you write
  `result.md`, the master is not polling it); do not close your own workspace or pane.
- Your `bash` runs under pi-sandbox (bwrap). `read`/`write`/`edit` and any
  extension tools are not OS-sandboxed, and the sandbox can be disabled; treat it
  as accident mitigation, not a security boundary.
- Never read `~/.pi/agent/auth.json` (the credential store) or another agent's
  session transcripts.
