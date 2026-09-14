---
name: typescript-lsp
description: Use for any task that reads, edits, or navigates .ts/.tsx files — invoke before grepping or editing to get LSP diagnostics, go-to-definition, and find-references instead of text search. Also diagnosing TS errors, refactoring TS code, or navigating a TypeScript project.
---

# typescript-lsp

Provides TypeScript language server integration via `typescript-language-server` for type checking, go-to-definition, hover info, diagnostics, and refactoring. Handles `.ts` and `.tsx` files.

## Steps

1. Confirm `typescript-language-server` is available on `$PATH` before diagnosing server startup issues.
2. The server requires a `tsconfig.json` in the project root for accurate type resolution. If types appear unresolved, check that the config exists and `include`/`paths` are correct.
3. For `.tsx` files the language ID is `typescriptreact`. If JSX diagnostics are missing, verify the file is being opened with the correct language ID.
4. When used alongside `angular-lsp`, this server handles `.ts` files only. Template diagnostics in `.html` files belong to `ngserver`.
