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

# asking questions

- Ask early: if a decision would change what gets built or how, and the user
  can answer in seconds, call `ask_user_question` right away instead of
  probing, trying several approaches, or looping.
- Do not overthink the wording: write the question the way you would in chat,
  with short option labels, and move on. Perfect wording costs more than it
  saves; the user can type a custom answer if no option fits.
- Batch related questions into one call; do not re-ask what the request
  already answers or what you can safely default.

# code style

- Self-documenting code; comment only what is not obvious.
- Always use braces in `if`/`for` blocks where the language supports them.
- Indent with 4 spaces.

# security

- Never read `~/.pi/agent/auth.json` (the credential store) or another agent's
  session transcripts.

# subagents

Offload substantive work to subagents via the `acp_delegate` tool instead of
editing inline. Delegate whenever the task is a bounded unit of
implementation, recon, or research; do it in the parent only for trivial
one-liners, final judgment, and acceptance.

- code review (bugs/risks) -> `reviewer`
- codebase recon / "where do I start" -> `researcher`
- make code changes -> `worker`
- propose a step-by-step plan -> `planner`
- answer questions / risky judgment -> `oracle`

Complex, multi-step, or parent-like work stays in this parent. All roles
inherit the parent model by default; pin per-role models in `acp.json` under
`delegate.agents.<role>.model`.

Every delegation names: objective, repo/cwd/ref, edit boundary, success
criteria, and expected output. Launch async by default; fetch the result with
a single `acp_delegate_wait` call, never poll.

Root-cause diagnosis stays in the parent (or a bounded read-only `oracle`),
never an async worker. Give a worker a hypothesis plus the concrete edit
plus the one check that verifies it, not "go diagnose". If the cause may live
in a dependency (node_modules rendered DOM, framework internals), say so in
the prompt and cap the dig: "read app code only; if the cause is inside a
dependency, report it in one sentence plus the single change you would make,
then stop."

Enforce the stop rule: for read-only diagnosis set
`toolBudget: { soft: 6, hard: 8, block: "*" }` (no more tool calls after 8;
the final answer is still allowed) and `control: { activeNoticeAfterTurns: 12 }`
so an active spin surfaces instead of running silently. Do not hard-cap a
mutation worker; give it a narrow task, a timeout, and a checkpoint instead.
