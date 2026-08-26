# Git Commit Skill

## Overview

Stages and commits changes to a local git repository using conventional commit syntax.

## Behavior

- Runs `git add` followed by `git commit` with a generated message
- Never push changes
- Prefers single-line commit messages
- Uses multi-line body only when the change genuinely requires explanation
- Never commits unrelated changes together
- Ask about any changes which are unrelated or unsure.
    - If asked to commit those changes infer the message


## Conventional Commit Format

```
<type>(<scope>): <short description>
```

**Types:**

- `feat` — new feature
- `fix` — bug fix
- `refactor` — code change that neither fixes a bug nor adds a feature
- `chore` — build, tooling, or dependency updates
- `docs` — documentation only
- `test` — adding or updating tests
- `perf` — performance improvement
- `style` — formatting, whitespace, no logic change
- `ci` — CI/CD configuration

**Scope** is optional. Use the module, file, or component name when it adds clarity.

## Message Rules

- Subject line: imperative mood, lowercase after the colon, no trailing period
- Max 72 characters on the subject line
- No filler words ("update", "fix stuff", "changes")
- Be specific: describe _what_ changed, not _that_ something changed

## Examples

```
feat(auth): add OAuth2 login flow
fix(api): return 404 when resource not found
refactor(parser): extract token validation to helper
chore: upgrade dependencies
docs(readme): add installation steps
test(cart): add unit tests for discount logic
```

## Multi-line Format (use sparingly)

```
fix(db): prevent duplicate inserts on retry

Adds idempotency key check before insert. Duplicate writes were
occurring when the client retried on timeout.
```

## Scope Guidelines

- Omit scope when the change is global or touches many areas
- Use the directory, package, or feature name as scope
- Keep scope lowercase and short (one word preferred)
