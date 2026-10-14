# Noop Plan

A placeholder plan to smoke-test the /plan skill: create a gitignored scratch
dir, write a plan, and gate on approval before any real work.

Status legend: `[ ]` not started · `[~]` in progress · `[x]` complete

## Context

Test run only. No code changes intended.

## Plan

- [ ] Smoke-test stage — confirm the scratch dir is gitignored and plan mode
  allows `__*` writes
  - confirm `/__*/` is present in `.gitignore`
  - acceptance: `git status` shows `__noop/` as ignored (once `/__*/` lands)

## Open questions

- [ ] none

## Risks

- none — noop
