---
name: angular-lsp
description: Use when working with Angular or Angular template (.html) files, diagnosing Angular/TypeScript errors, checking template bindings, refactoring components, or navigating an Angular project. Trigger phrases: "fix Angular error", "check template", "refactor component", "go to definition", "check bindings", "diagnose Angular".
---

# angular-lsp

Provides Angular and TypeScript language server integration for Angular projects. Covers template diagnostics, type checking, go-to-definition, hover info, and component/service navigation.

Two LSP servers run together:

- `typescript-language-server` handles `.ts`/`.tsx` files
- `ngserver` handles `.html` Angular templates

## Steps

1. Confirm the project has `node_modules` at its root (both `--tsProbeLocations` and `--ngProbeLocations` point there).
2. Use the Angular LSP for template diagnostics and binding issues in `.html` files.
3. Use the TypeScript LSP for `.ts` errors, refactors, and type navigation.
4. When diagnosing errors, check both servers' output since template errors surface in `ngserver` and type errors in `typescript-language-server`.
