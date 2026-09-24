# Environment

Editor: Neovim.

Two machines, distinguished by the `$COV` environment variable. Check `$COV`
before suggesting shell commands, paths, or config changes.

- `$COV=1`: work machine. WSL (Debian) on Windows 11. All work happens inside
  WSL. Packages are managed with Nix and Home Manager.
- `$COV` unset: personal machine. Full NixOS install.

# Tools

Available on both machines:

`git`, `gh`, `rg`, `grep`, `find`, `jq`, `make`, `just`, `cmake`, `node`,
`pnpm`, `tsc`, `python3`, `cargo`, `clang`, `mvn`, `curl`, `wget`, `parallel`,
`tmux`, `awscli2`, `direnv`, `unzip`, `zip`

# Language

Write in English only: code, comments, docs, examples, commits, configs, error
messages, and tests.

# Writing Style

No em dashes (U+2014), en dashes (U+2013), or emojis anywhere: not in code,
prose, or filenames. Use commas, colons, parentheses, or plain hyphens instead.

# Response Style

- Be succinct and direct.
- Ask clarifying questions rather than making assumptions.
- Read the minimum needed; ask before large exploration or read-heavy steps.

# Code Style

- Prefer self-documenting code; avoid comments that restate what the code does.
- Always use braces in `if` and `for` blocks in languages that support them.
- Default to 4-space indentation.

# File reading

To view part of a file, use the built-in `read` tool with `offset` (1-based
first line) and `limit` (line count). Never use `sed`, `awk`, `perl`, `cut`,
or shell redirection to read files: `read` is read-only and never triggers an
approval prompt, while `sed -i` can mutate files in place.

Don't `cd` into a directory just to read a file: pass the full path to `read`
directly. `cd` is a bash command and gets caught by the approval gate; a plain
`read path=...` never does.

- `sed -n '101,170p' f` → `read path=f offset=101 limit=70`
- `sed -n '1,50p' f` → `read path=f limit=50`
- `cat f` → `read path=f`
- `cd dir && cat f` → `read path=dir/f`

# Searching

Use `rg` (ripgrep) over traditional `grep` for all text searches: it is faster,
respects `.gitignore` by default, and supports modern regex syntax. Prefer `rg
--hidden` when searching dotfiles or hidden files.

# pi-coding-agent docs

The coding agent's own documentation lives in the nix profile (stable,
hash-free) under `~/.nix-profile/lib/node_modules/pi-monorepo/`:

- `README.md` is the entry point; read it first for core concepts and links.
- `docs/` holds one markdown file per topic. Read only the file matching the
  current task, not the whole folder.
- `examples/` holds working code for extensions, plugins, and SDK integrations.

Always read these with the built-in `read` tool and the full `~/.nix-profile`
path (for example `read path=~/.nix-profile/lib/node_modules/pi-monorepo/docs/tui.md`).
The `read` tool is not sandboxed and follows the profile symlink, so it never
triggers an approval prompt.

Never search or open these paths with `rg`, `find`, `cat`, or any bash command:
the sandboxed shell resolves `~/.nix-profile` to `/nix/store/...`, which is
outside `allowRead`, and globbing `/nix/store/*` hangs by walking the whole
store. Use `read` instead.