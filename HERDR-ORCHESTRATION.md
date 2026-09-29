# Herdr + pi-agent orchestration notes

Purpose: handoff doc for a new agent. Everything here was verified against source
or experimentally in this repo (`~/.dotfiles`), not assumed. The goal is to codify
one repeatable pattern:

> A master pi agent dispatches sub-agents (full pi processes) through the herdr
> server; each sub-agent's bash tool calls are constrained by pi-sandbox. The
> sandbox is accident mitigation, not a security boundary.

## The pattern

- **Master**: a full `pi` session. It can stay sandboxed. Dispatching goes over
  the herdr socket to the already-running herdr server, so the master never needs
  to spawn a child as its own process. It orchestrates; it does not do risky work
  itself.
- **Sub-agents**: full `pi` processes (not pi-subagents) in herdr tabs/panes.
  Whether their bash calls are constrained depends on their own sandbox config.

Key distinction from pi-subagents: pi-subagents run in-process and share the
master's context and tools. This pattern gives a separate process, a separate
session, herdr visibility, and OS-level constraints on `bash`. It does **not** by
itself give process-level security isolation; see the next section.

## What the sandbox is and is not (read this first)

pi-sandbox is accident/damage mitigation, not a confinement boundary:

- Only `bash` is constrained at the OS level (bwrap). The `read`, `write`, and
  `edit` tools run inside the pi Node.js process, unsandboxed, and are only
  prompt-gated. (pi-sandbox README: "The OS-level sandbox cannot cover these
  tools because they run directly in the Node.js process.")
- `denyRead` is **not** a hard block for the `read` tool. The read hook checks
  allowRead/allowWrite prefixes, not denyRead. Concretely: `~/.pi/agent` is in
  `allowRead`, so `read ~/.pi/agent/auth.json` returns the real API-key file with
  no prompt. The `/dev/null` stub only protects `bash`.
- The child can disable its own sandbox with no human gate: `--no-sandbox`, the
  `Alt+S` toggle, or `/sandbox-disable`.
- Any other tool a full pi child loads (extensions, pi-subagents, MCP servers,
  web/browser skills) runs entirely outside pi-sandbox.

If OS-level isolation is the actual goal, containerize the whole child `pi`
process (scoped mounts, or pi's documented container/VM approach for untrusted
work). pi-sandbox alone is not that. The findings below therefore describe the
*bash* sandbox, not a security perimeter around the child.

## Verified findings

### 1. Sandboxing is per-tool-call, not per-process

`pi-sandbox` does not confine the agent process. It wraps each bash tool call in a
fresh `bwrap` invocation. Observed flags (confirmed in
`@carderne/sandbox-runtime/dist/sandbox/linux-sandbox-utils.js`):

- `--new-session --die-with-parent --unshare-net --unshare-pid --unshare-user --cap-drop ALL --proc /proc`
- `--ro-bind / /` (filesystem starts read-only), then `--bind` for each `allowWrite` path; `--dev /dev`
- `--ro-bind /dev/null <path>` over `denyRead` files and over `denyWrite` targets
  that do not exist yet, which is why `auth.json` and a not-yet-created `.env`
  appear as char devices `1,3` owned `nobody:nogroup`. A `denyWrite` path that
  already exists inside an `allowWrite` tree is instead ro-bound over itself: it
  stays visible but unwritable, not masked as a char device.
- network via a local `socat` proxy to a unix socket, gated by `allowedDomains`
- `--setenv SANDBOX_RUNTIME 1`

A running sandbox is observable from inside bash by:

```sh
echo "${SANDBOX_RUNTIME:-unset}"      # 1 when sandboxed
ls -l ~/.pi/agent/auth.json           # char device (1,3) nobody:nogroup when stubbed
touch ~/.pi/agent/__probe && echo WRITABLE || echo READONLY
```

### 2. Direct child processes die; herdr-mediated spawn survives

The bwrap wrapper runs with `--die-with-parent`, and the wrapping shell has a
`trap "kill %1 %2; exit" EXIT`. Any process backgrounded *directly* from a
sandboxed bash (a spawned `pi`, or a `tmux` server hosting one) is killed the
moment the bash tool command returns.

But `herdr agent start` is not a direct fork: it is a request over the unix socket
to the already-running herdr server daemon, which lives outside the sandbox
namespace and parents the new `pi`. The `--die-with-parent` kill never reaches it.

Verified live: from a sandboxed `bash` (`SANDBOX_RUNTIME=1`), `herdr tab create` +
`herdr agent start probe-sandbox --kind pi` produced an agent still `idle` and
listed in a later, separate sandboxed shell. The master therefore does **not**
need to be unsandboxed to dispatch via herdr (the live `sandbox.json` has
`allowAllUnixSockets: true`, so the herdr socket stays reachable from the sandbox).

Consequence: a sandboxed master can dispatch persistent sub-agents through the
herdr server; it just cannot spawn them as its own direct child processes. The
one non-model seat with real authority is the herdr server, which is what you
want.

### 3. The child constrains only its own bash, and can turn that off

A child spawned through herdr has its bash wrapped only because it loads
pi-sandbox itself from the shared `~/.pi` config (`enabled: true`). Verified by
having such a child run the probe itself; its own tool output was:

```
SANDBOX_RUNTIME=1
crw-rw-rw- 1 nobody nogroup 1, 3 ... /home/cvhew/.pi/agent/auth.json
touch: cannot touch '...': Read-only file system
READONLY
```

This is mitigation, not a boundary: the child can self-disable (`/sandbox-disable`),
and its non-bash tools were never sandboxed. Do not phrase this as "the child is
sandboxed for all its actual work"; phrase it as "the child's bash calls are
bwrap-constrained while the sandbox stays on, which is advisory."

### 4. herdr is the substrate; agents must run in herdr panes

herdr only detects agents running inside its own panes. A `pi` started in a
random `tmux` server is invisible to herdr. herdr tracks each agent's lifecycle
(`idle`, `working`, `blocked`, `done`, `unknown`) and its session path
(`herdr:pi` -> the `~/.pi/agent/sessions/...` file).

Elements and opaque IDs (from the focused session in this repo):

- `HERDR_ENV=1` is set inside a managed pane (guard for "am I inside herdr"); the
  master itself should be a herdr-managed pane.
- workspace `w5`, tab `w5:t1`, master pane `w5:p1`, project `~/.dotfiles`
- `$HERDR_WORKSPACE_ID`, `$HERDR_TAB_ID`, `$HERDR_PANE_ID` carry the caller context

Before controlling herdr, re-read the authoritative instructions with
`herdr --skill` (it is the current-syntax authority and includes safety rules).

## Exact commands that work today

Spawn a sub-agent in a **new tab** (not a pane) of the current workspace:

```sh
herdr tab create --workspace "$HERDR_WORKSPACE_ID" --cwd "$PWD" --no-focus
# -> { "result": { "tab": { "tab_id": "w5:tD" }, "root_pane": { "pane_id": "w5:pE" } } }
# parse with jq: .result.tab.tab_id and .result.root_pane.pane_id

herdr agent start pi2 --kind pi --pane <root_pane_id>
# -> agent name pi2, status idle, interactive_ready true
```

Coordinate with it via the agent surface:

```sh
herdr agent prompt pi2 "<task>" --wait --timeout 120000
herdr agent read   pi2 --source recent-unwrapped --lines 120
herdr agent get    pi2
herdr pane send-text <pane_id> "/quit" && herdr pane send-keys <pane_id> enter  # quit (documented path)
herdr agent send-keys pi2 ctrl+d      # also quits pi 0.86.1 (app.exit), verified empirically but not a herdr-validated logical key
herdr pane close <pane_id>            # then close its pane/tab
herdr agent list                      # inventory / status
```

Sibling pane (same tab) alternative to a new tab:

```sh
herdr pane split --current --direction right --cwd "$PWD" --no-focus
# -> { "result": { "pane": { "pane_id": "w5:pD" } } }
herdr agent start pi2 --kind pi --pane <returned_pane_id>
```

## Communication and token efficiency

The expensive part of the current loop is result handoff. `herdr agent read` pulls
TUI scrollback, which includes ANSI, re-echoed commands, prompt chrome, and
partial renders. Use the cheap channel: the child writes its final answer to a
file and the master reads only that file with its own `read` tool (herdr's own
docs recommend exactly this).

## Suggested approach (three pieces, not a framework)

1. **One dispatch command.** A pi skill and/or a short shell script wrapping the
   loop: `tab create -> agent start --kind pi -> inject task -> wait done -> read
   result -> reap tab`. Centralizes naming, cwd policy, and reaping. Before spawn,
   write a per-task record to an on-disk `state/` dir (task id, run dir, tab/pane
   id, status) so the master can reconcile and reap after a restart instead of
   holding the mapping only in memory. Target children by the recorded exact id
   and refuse on ambiguity.

   Implemented as `pi-dispatch` (see below).

2. **File result channel.** Child writes its final answer to a per-run directory
   and the master reads only that file. `$RUN_DIR` must be in the child's
   `allowWrite` (e.g. `mktemp -d` under `/tmp`, never the git-versioned repo), and
   teardown removes it. Completion should not depend on the model remembering to
   write: a `turn_end`/`agent_settled` hook the child loads can atomically write
   the result and a completion marker at turn settlement, with the model's `DONE`
   reply left as an advisory hint only (firstmate's "scripts report facts, agents
   report judgement" rule).

3. **Sandbox check, not sandbox gate.** Do not call it a trust boundary. Any
   probe is run by the child and reported through its own output, so it is
   unauthenticated self-report, point-in-time, and survives no later
   `/sandbox-disable`. It is at most a configuration sanity check. For real
   isolation, containerize the whole child process instead.

## Current implementation: `pi-dispatch`

`home/_scripts/.scripts/pi-dispatch`, stowed to `~/.scripts/pi-dispatch` (on PATH).
After adding or editing it, run `just stow` outside the sandbox.

```
pi-dispatch <task...>         spawn one sub-agent, run it, print the result, reap the tab
pi-dispatch --cwd DIR <task...>     same, but the worker sits in DIR (another project/repo)
pi-dispatch --branch NAME <task...> create a worktree+branch NAME off DIR; the worker commits there, the checkout is removed on completion, the branch is kept
printf 'task' | pi-dispatch   task from stdin
pi-dispatch --keep <task...>  leave the tab and run dir for inspection
pi-dispatch --reap            close tabs recorded by dispatches that died mid-run
```

Flow: spawn the worker on one of three paths: default `tab create` (new tab,
`--no-focus` in the current workspace), `--cwd DIR` (same tab, but it sits in
DIR), or `--branch NAME` (a `herdr worktree create` checkout off DIR/`$PWD`; the
tab sits in that checkout). Then `agent start --kind pi` -> write the
task to `/tmp/pi-dispatch.<id>/brief.md` -> `agent prompt ... --wait --until idle`
the child (read the brief, do the work, write the final answer to
`/tmp/pi-dispatch.<id>/result.md`, reply `DONE`); `--wait` tracks the
working->idle transition so it returns when the turn settles -> print
`result.md`, or the transcript tail if the child settled without writing it ->
reap (graceful `ctrl+d`, then close the tab; on the `--branch` path, remove the
worktree checkout while keeping the branch).

State and cleanup:

- Durable record written before spawn: `~/.local/share/pi-dispatch/<id>.json`
  (id, agent name, tab/pane ids, run dir, task, start time, branch, cwd,
  checkout_path, wt_workspace). `--reap` reads these and closes any tab or
  worktree workspace that still exists, then removes the record. A `trap ... EXIT`
  reaps the tab (or worktree checkout) and run dir on every normal-exit path;
  `--keep` skips it.
- Run dirs live under `/tmp` (inside the child's `allowWrite`; never the repo).
- The `--branch` checkout directory embeds the worker's process name, so an
  on-disk checkout can be traced to its worker:
  `~/.herdr/worktrees/<repo>/<branch>-pi-<id>`.
- Result contract: the first line of `result.md` is `status: done` or
  `status: failed`; pi-dispatch exits non-zero when the worker reports `failed`.

Gotchas hit while building (do not relearn these):

- herdr agent names must match `^[a-z][a-z0-9_-]{0,31}$`. The `mktemp` random
  suffix has uppercase, and the template dot is illegal; the script strips the
  `pi-dispatch.` prefix, lowercases, and strips dots before prefixing `pi-`.
- Register the reap `trap` (an earlier revision forgot it and leaked tabs and
  state files).
- Do not swallow herdr stderr: on failure herdr returns JSON on stderr with a
  non-zero exit, so capture `2>&1` in the `$(...)`; `herdr ... 2>/dev/null` under
  `set -e` aborts silently and hides the real reason (e.g. `invalid_agent_name`).

Verified end to end: a trivial task returned `pong` in ~10s with a clean reap (no
stray tabs, no state files). The dispatched child's own bash calls are
bwrap-sandboxed as described above; the limits of that are in "What the sandbox
is and is not".

Known ceilings (deliberate simplifications):

- Completion is herdr-detected (`agent prompt --wait --until idle/done/blocked`);
  but a `turn_end` extension could still write a precise completion marker if the
  herdr state ever proves unreliable. The transcript-tail fallback covers a child
  that settles without writing `result.md`.
- `--reap` is manual, not a background reconciler.
- Single dispatch only; no parallel fanout yet.

## Explicitly not building (YAGNI)

- No daemon or supervisor (herdr already tracks lifecycle)
- No result protocol or socket RPC (files are enough)
- No new sandbox engine (pi-sandbox already wraps the child's bash calls)
- No per-child config system yet (children share `~/.pi`; revisit only if a child
  must not see the master's credential store)

## Credentials and env, by spawn context

- **Normal herdr pane (master or child)**: the process uses the real `~/.pi`, so
  no flags are needed; settings/extensions/creds load normally. This is why a
  child can `read` the master's real `auth.json` (allowRead `~/.pi/agent` beats
  the `denyRead` stub, which only bash sees). If a child must not see credentials,
  give it a scoped `PI_CODING_AGENT_DIR` with its own config, or containerize it.
- **Inside a sandbox's own bash**: `~/.pi` is mounted read-only and `auth.json` is
  a `/dev/null` stub, and any *directly spawned* child dies with the sandbox
  (`--die-with-parent`). These do **not** stop herdr-mediated dispatch (see
  finding 2), so this is not a reason to unsandbox the master.
  Working flags if a one-shot, non-persistent child is ever wanted:

  ```sh
  PI_CODING_AGENT_DIR=/tmp/pi-child pi --no-session \
    --provider openrouter --model deepseek/deepseek-v4-pro-0813 \
    --api-key "$OPENROUTER_API_KEY" -p "say hello"
  ```

## pi facts (0.86.1)

- exit `/quit`; interrupt `Escape`; `app.exit = ctrl+d`
- resume `--session <path-or-id>`; one-shot `--no-session`
- `--model <provider>/<id>` with `--provider <provider>`; effort
  `--thinking off|minimal|low|medium|high|xhigh|max` (the `off`/`minimal` levels
  are newer than firstmate's pinned 0.82 facts)
- one positional instruction: `pi [options] [--] [@files...] [messages...]`
- `PI_CODING_AGENT_DIR` overrides the config dir (default `~/.pi/agent`)

## Repo context

- NixOS (personal machine, `$COV` unset), nix + home-manager, stow-managed dotfiles.
- `just stow` links `home/<pkg>` into `~`; do not edit under `~` directly.
- pi runs at `/home/cvhew/.nix-profile/bin/pi` (v0.86.1); herdr 0.9.1.
- Sandbox config lives at `~/.pi/agent/sandbox.json`, stowed from
  `home/_pi/.pi/agent/sandbox.json`: `enabled: true`, `allowAllUnixSockets: true`,
  `denyRead` includes `~/.pi/agent/auth.json` (bash-only stub), `allowRead`
  includes `~/.pi/agent` (read tool sees the real files), and `allowWrite` is
  `[".", "/tmp", "~/.cache", "~/.local/share", "~/.pnpm/", "~/code"]` (`~/code`
  was added so workers can git-commit inside `~/code` repositories; verified end
  to end).