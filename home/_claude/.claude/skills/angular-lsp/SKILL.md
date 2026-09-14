---
name: angular-lsp
description: Use for any task that reads, edits, or navigates .ts or Angular template .html files in an Angular project — invoke before grepping or editing to get LSP diagnostics, template binding checks, go-to-definition, and find-references instead of text search. Also diagnosing Angular/TypeScript errors or refactoring components.
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
