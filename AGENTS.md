# This repo

Git-versioned dotfiles, managed with GNU stow and a Nix flake.

## Layout

- `home/<name>/` - stow packages. Contents link directly under `~`
  (`home/_pi/.pi/` -> `~/.pi/`, `home/_nvim/.config/nvim/` -> `~/.config/nvim/`).
  The `_` prefix is a package-name convention only.
- `nix/` - the flake: NixOS (`just main`), home-manager for the work
  (`just cov`) and mac (`just mac`) hosts, plus `modules/`.
- `ansible/` - playbook for hosts not managed by nix.
- `justfile` - task runner; `just -l` lists everything.

## Workflow

1. Edit files here under `home/<name>/`, never in `~` (those are stow symlinks).
2. `just stow` links all `home/` packages into `~`.
3. `just main` / `just cov` rebuild a host and commit.
4. `just _commit` commits and pushes a timestamped commit (use after manual edits).

## Todo (`~/todo/todo.md`)

The `todo` command (`home/_shell/.bashrc`) opens `~/todo/todo.md` in nvim.
All todo behavior lives in nvim config:

- `home/_nvim/.config/nvim/lua/config/key_bindings.lua` - `<leader>st`
  (telescope search over `~/todo`), `<leader>ta`/`:TodoArchive`, `:TodoSort`,
  and auto-archive on `BufWritePre`. `<leader>st`/`<leader>ta` bind only in the
  `~/todo/todo.md` buffer (path-matched, not filetype).
- `home/_nvim/.config/nvim/lua/plugin/vim_simple_todo.lua` - markdown
  checkbox keymaps (`<leader>i`/`o`/`O`/`x`).

Conventions:
- Tasks are `- [ ]` / `- [x]`; archive headings are `## YYYY-Www`.
- Archive: newest week first; within a week newest completed first; one blank
  line before and after each heading (matches the markdown formatter).
- `TodoSort` sorts the whole buffer and is not archive-aware; do not auto-apply
  it to a file that already has `## YYYY-Www` sections.

## Rules

- This file documents conventions, not an inventory. A new package is just
  `home/_<name>/` plus `just stow`; adding one should not require editing this.
- Never commit runtime state or secrets. `~/.pi/agent/` holds real runtime
  files (sessions, git, npm, auth.json); `.gitignore` and the git global
  exclude cover `.env*`, credentials, and pi state.
- pi-sandbox makes `~/.pi` read-only and mounts `/dev/null` char-device stubs
  over the repo-root dotfiles, so `just stow` and `just _commit` (its
  `git add .` fails with "can only add regular files") must run outside the
  sandbox. Agent toggles `--skip-worktree`; operator runs `just _commit`.
- If a git, file, or shell command fails inside an agent session, assume the
  sandbox (read-only mounts, `/dev/null` stubs, denied paths) is the cause
  before blaming the command or the repo. Do not keep retrying or work around
  it silently; escalate to the user with the exact command to run and handle
  whatever parts do work in-sandbox yourself.
- `home/_pi/.pi/agent/settings.json` is locally `git update-index --skip-worktree`d.
  pi rewrites it on every thinking toggle / version bump, so git status ignores
  those edits and `just _commit` will not pick them up. To commit a real settings
  change, first `git update-index --no-skip-worktree home/_pi/.pi/agent/settings.json`,
  commit, then re-run `--skip-worktree`.
- Char-device stubs at the repo root (`.bashrc`, `.zshrc`, `.gitconfig`, `.env`,
  `.mcp.json`) are `/dev/null` sandbox mounts, not repo files; ignore them.
