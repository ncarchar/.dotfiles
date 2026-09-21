# CLAUDE.md

## Language

English only: code, comments, docs, examples, commits, configs, errors, tests.

## Project Context

Primary stack: Angular, TypeScript, Java, Spring Boot, AWS CDK, AWS SDK, Postgres.

## Git Commits

Format: `<type>(<scope>): <subject>`
Types: `feat|fix|docs|style|refactor|test|chore|perf`

- Subject: 50 chars max, imperative mood ("add" not "added"), no period
- Small to Large changes: one-line commit only no body
- Complex changes: add body explaining what/why (72-char lines), reference issues
- Keep commits atomic (one logical change); split if addressing different concerns
- Never reference Claude or Anthropic in the commit message
- Never push changes unless explicitly asked to

## Code Style

- Prefer self-documenting code; avoid comments that restate what the code does
- Always use braces/brackets in `if` and `for` blocks in languages that support them
- Explicit error handling over silent failures

## Response Style

- Be succinct and direct
- Ask clarifying questions when needed rather than making assumptions
- Do not overly explore the code base or run large explore loops that use a lot of tokens to read random files!
- Use the minimum reasonible amount of reads/exploring. Ask before large explore steps.

## Safety

- Ask before running destructive commands (`rm -rf`, `git reset --hard`, `DROP`, etc.)
- Do not commit or push without confirmation
- Never log, echo, or commit `.env` files, secrets, tokens, or credentials

## Environment

Editor: Neovim.

Two machines, distinguished by `$COV`:

- `$COV=1`: work machine. WSL (Debian) on Windows 11. All work occurs inside WSL. Packages managed via Nix and Home Manager.
- `$COV` unset: personal machine. Full NixOS install.

Tailor shell commands, paths, and config suggestions to the active environment.

## Tools

`git`, `gh`, `rg`, `grep`, `find`, `jq`, `make`, `just`, `cmake`,
`node`, `pnpm`, `tsc`, `python3`, `cargo`, `clang`, `mvn`, `curl`, `wget`,
`parallel`, `tmux`, `awscli2`, `direnv`, `unzip`, `zip`

## Skills

### graphify

- **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
  When the user types `/graphify`, use the installed graphify skill or instructions before doing anything else.

### angular-lsp

- **angular-lsp** (`~/.claude/skills/angular-lsp/SKILL.md`) - Angular and TypeScript LSP integration. Trigger: `/angular-lsp`
  Use automatically when working in Angular projects (.ts, .html component files). When the user types `/angular-lsp`, use the installed skill before doing anything else.

### java-lsp

- **java-lsp** (`~/.claude/skills/java-lsp/SKILL.md`) - Java LSP integration via Eclipse JDT LS. Trigger: `/java-lsp`
  Use automatically when working in Java or Spring Boot projects. When the user types `/java-lsp`, use the installed skill before doing anything else.

### typescript-lsp

- **typescript-lsp** (`~/.claude/skills/typescript-lsp/SKILL.md`) - TypeScript LSP integration. Trigger: `/typescript-lsp`
  Use automatically when working in TypeScript projects (.ts, .tsx files). When the user types `/typescript-lsp`, use the installed skill before doing anything else.
