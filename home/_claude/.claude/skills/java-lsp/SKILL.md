---
name: java-lsp
description: Use when working with Java files, diagnosing Java errors, refactoring Java code, navigating a Java project, or working with Spring Boot. Trigger phrases: "fix Java error", "check types", "refactor Java", "go to definition", "diagnose Java", "Spring Boot issue".
---

# java-lsp

Provides Java language server integration via Eclipse JDT LS for type checking, go-to-definition, hover info, diagnostics, and refactoring. Configured with Lombok support and tuned JVM settings (1g min, 4g max, G1GC).

## Environment

Server jars and config are installed under `/home/cvhew/.local/share/nvim/mason/packages/jdtls/`. Workspace data is isolated per project using `${CLAUDE_PROJECT_DIR}`.

## Steps

1. Confirm `jdtls` is installed at the expected mason path before diagnosing server startup issues.
2. Lombok is loaded via `-javaagent` at startup. If annotation processing seems broken, verify the `lombok.jar` path is intact.
3. Workspace data lives at `${CLAUDE_PLUGIN_DATA}/workspaces/${CLAUDE_PROJECT_DIR}`. If the project state is stale or corrupt, clearing that workspace directory forces a clean reimport.
4. For Spring Boot projects, ensure the project is recognized as a Maven or Gradle project so JDT LS resolves the classpath correctly.
5. JVM args include `--add-opens` for `java.util` and `java.lang`. If reflection-related errors appear at runtime, check those first.
