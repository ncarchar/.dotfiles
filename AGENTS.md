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

## Rules

- This file documents conventions, not an inventory. A new package is just
  `home/_<name>/` plus `just stow`; adding one should not require editing this.
- Never commit runtime state or secrets. `~/.pi/agent/` holds real runtime
  files (sessions, git, npm, auth.json); `.gitignore` and the git global
  exclude cover `.env*`, credentials, and pi state.
- pi-sandbox makes `~/.pi` read-only inside an agent session, so `just stow`
  must run outside the sandbox.
- `home/_pi/.pi/agent/settings.json` is locally `git update-index --skip-worktree`d.
  pi rewrites it on every thinking toggle / version bump, so git status ignores
  those edits and `just _commit` will not pick them up. To commit a real settings
  change, first `git update-index --no-skip-worktree home/_pi/.pi/agent/settings.json`,
  commit, then re-run `--skip-worktree`.
- Char-device stubs at the repo root (`.bashrc`, `.zshrc`, `.gitconfig`, `.env`,
  `.mcp.json`) are `/dev/null` sandbox mounts, not repo files; ignore them.
