---
name: sources
description: Clone a public GitHub repo at a given version into a temp cache and have a read-only researcher answer a question from its source. Use when the user wonders how something works in a library at a specific version (e.g. ngrx signal store 19.x) and the answer needs the library's actual code.
allowed-tools:
    - Bash(~/.pi/agent/skills/sources/scripts/*)
---

# Sources

Answer "how does X work in library Y at version Z" from the real source without
loading it into this context.

## Steps

1. Pick `owner/name` and a ref: a tag or branch matching the version the project
   uses (check its lockfile). No ref means the default branch.
2. Run `~/.pi/agent/skills/sources/scripts/sources.sh <owner/name> [ref]`. It
   prints the clone path (`~/.cache/pi-sources/<owner>/<name>@<ref>`), reuses an
   existing clone, and deletes clones unused for 30 days. If the ref is not found,
   the error shows the `git ls-remote --tags` command to find the right tag name.
3. Delegate one `researcher` with `acp_delegate`, `cwd` set to the clone path,
   `async: false`. The task states: the question and the project's version and
   context, "read-only, do not build, install, or edit", and asks for a short
   answer citing `path:line`, with a snippet only where essential. Set
   `toolBudget: { soft: 15, hard: 25, block: "*" }`.
4. Relay the answer. Do not read the clone yourself unless the answer needs a
   spot check.

Public repos only: a private repo fails fast. Ask the user to clone it outside
the sandbox.
