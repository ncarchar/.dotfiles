# Rules of engagement

These override all defaults. Follow every one, no exceptions.

1. Always write in English: code, comments, docs, prose, tests.
2. No em dashes, en dashes, or emojis, anywhere.
3. Read files with the `read` tool only. Never `sed`/`awk`.
4. Use `rg`, not `grep`.

# Environment

`$COV=1` = work machine: WSL (Debian), Nix + Home Manager.
`$COV` unset = personal machine: NixOS.

# pi-sandbox dotfile stubs

`pi-sandbox` (the `npm:pi-sandbox` package) wraps every bash command in an
OS-level sandbox (bubblewrap on Linux). It protects sensitive filenames by
mounting `/dev/null` over them, e.g. `.gitconfig`, `.bashrc`, `.bash_profile`,
`.zshrc`, `.zprofile`, `.profile`, `.ripgreprc`, `.mcp.json`, plus `denyWrite`
patterns from `~/.pi/agent/sandbox.json` such as `.env`. When one of these
names does not exist yet at the session root, bwrap creates a mount point there.

These mount points surface in the working directory as character devices, not
regular files, and are harmless. Identify them with `ls -la`:

- type `c` (`crw-rw-rw-`), device type `1, 3` (= `/dev/null`), size 0
- owner `nobody:nogroup`

They are not repo files, not secrets, and not leaked host dotfiles. They hold
no data and cannot be read. Do not flag them as leaks, and do not read, parse,
edit, or commit them. Ignore them; they are sandbox side effects, not project
content.

# Tools

Available on both machines:

`git`, `gh`, `rg`, `grep`, `find`, `jq`, `make`, `just`, `cmake`, `node`,
`pnpm`, `tsc`, `python3`, `cargo`, `clang`, `mvn`, `curl`, `wget`, `parallel`,
`tmux`, `awscli2`, `direnv`, `unzip`, `zip`

# Response Style

- Reply in a succinct manner and in a way that is easy for the user to understand.
- If a requirement is ambiguous, ask before acting.
- Read only what the task needs; ask before a large or read-heavy step.

# Code Style

- Use self-documenting code; comment only what is not obvious.
- Always use braces in `if` and `for` blocks in languages that support them.
- Indent with 4 spaces.

# File reading

To view part of a file, use the built-in `read` tool with `offset` (1-based
first line) and `limit` (line count). Never use `sed`, `awk`, `perl`, `cut`.
`read` is read-only and never triggers an approval prompt, while `sed -i`
can mutate files in place.

- `sed -n '101,170p' f` → `read path=f offset=101 limit=70`
- `sed -n '1,50p' f` → `read path=f limit=50`
- `cat f` → `read path=f`

# pi-coding-agent docs

The coding agent's own documentation lives in the nix profile (stable,
hash-free) under `~/.nix-profile/lib/node_modules/pi-monorepo/`:

- `README.md` is the entry point; read it first for core concepts and links.
- `docs/` holds one markdown file per topic. Read only the file matching the
  current task, not the whole folder.
- `examples/` holds working code for extensions, plugins, and SDK integrations.
