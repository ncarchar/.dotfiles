---
name: java-lsp
description: Use for any task that reads, edits, or navigates .java files — invoke before grepping or editing to get LSP diagnostics, go-to-definition, and find-references instead of text search. Also diagnosing Java errors, refactoring Java code, or working with Spring Boot.
allowed-tools:
    - Bash(java *)
    - Bash($HOME/.local/share/nvim/mason/packages/jdtls/*)
---

# java-lsp

Provides Java language server integration via Eclipse JDT LS for type checking, go-to-definition, hover info, diagnostics, and refactoring. Configured with Lombok support and tuned JVM settings (1g min, 4g max, G1GC).

## Environment

Server jars and config are installed under `$HOME/.local/share/nvim/mason/packages/jdtls/` (do not hardcode a username; this resolves correctly on both the work and personal machines). Workspace data is isolated per project using `${CLAUDE_PROJECT_DIR}`.

## Steps

1. Confirm `jdtls` is installed at the expected mason path before diagnosing server startup issues.
2. Lombok is loaded via `-javaagent` at startup. If annotation processing seems broken, verify the `lombok.jar` path is intact.
3. Workspace data lives at `${CLAUDE_PLUGIN_DATA}/workspaces/${CLAUDE_PROJECT_DIR}`. If the project state is stale or corrupt, clearing that workspace directory forces a clean reimport.
4. For Spring Boot projects, ensure the project is recognized as a Maven or Gradle project so JDT LS resolves the classpath correctly.
5. JVM args include `--add-opens` for `java.util` and `java.lang`. If reflection-related errors appear at runtime, check those first.
