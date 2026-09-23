---
name: hello-example
description: Demonstrates the pi skill format. Prints a greeting, the current directory, and git status. Use as a template when creating new skills.
---

# Hello Example

A minimal skill to copy when creating new pi skills.

## Usage

```bash
echo "Hello from the hello-example skill (cwd: $(pwd))"
git status --short
```

## Adding helper scripts

Drop executables into a `scripts/` directory next to this file and reference
them with relative paths, e.g. `scripts/do-something.sh`. Any extra files
(`references/`, `assets/`, etc.) are freeform.
