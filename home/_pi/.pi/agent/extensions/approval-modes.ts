/**
 * Approval Modes Extension - Claude Code-style plan/manual/auto edit approvals.
 *
 * /plan    - read-only: write/edit and non-read-only bash are blocked, and the
 *            model is steered to produce a structured implementation plan.
 * /manual  - each write/edit (and non-read-only bash) prompts Approve/Reject.
 * /auto    - write/edit and known-safe bash apply automatically (default).
 * shift+tab - cycles auto -> manual -> plan -> auto.
 *
 * Bash classification (readonlyBash / safeBash / unsafePatterns) loads from
 * ~/.pi/agent/pledit.json; built-in defaults apply when the file is absent.
 *
 * pi-sandbox is the real OS-level guard underneath (bwrap blocks writes to
 * paths outside allowWrite and blocks unlisted domains). unsafePatterns here
 * is belt-and-suspenders for high-signal destructive commands, not a sandbox.
 */

import {
  getAgentDir,
  getLanguageFromPath,
  highlightCode,
  type ExtensionAPI,
  type ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import { Input, Key, matchesKey, truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";
import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";

// Built-in tools that mutate files. bash is gated except for read-only commands.
const WRITE_TOOLS = new Set<string>(["edit", "write", "bash"]);

type BashClass = "readonly" | "safe" | "unsafe";

interface BashConfig {
  readonlyBash: string[];
  safeBash: string[];
  unsafePatterns: string[];
}

// Fallback lists used when ~/.pi/agent/pledit.json is missing or malformed.
// The committed config file carries the live copy; keep these in sync.
const DEFAULT_BASH: BashConfig = {
  readonlyBash: [
    "cat", "head", "tail", "less", "more", "grep", "rg", "find", "ls", "pwd", "cd",
    "wc", "sort", "uniq", "diff", "file", "stat", "du", "df", "tree", "which", "type",
    "whereis", "env", "printenv", "uname", "whoami", "id", "date", "uptime", "ps",
    "bat", "eza", "jq", "echo", "printf", "node --version", "npm --version", "git --version",
    "git status", "git diff", "git log", "git show", "git branch", "git remote",
    "git ls-", "git stash list", "git blame", "git tag", "git rev-parse",
    "git config", "git ls-files", "git reflog", "git shortlog", "git describe",
    "npm list", "npm ls", "npm view", "npm info", "npm search", "npm outdated", "npm audit",
  ],
  safeBash: [
    "mkdir", "touch", "mv", "cp", "rm", "rmdir", "ln", "chmod", "chown",
    "sed", "awk", "tr", "tee", "dirname", "basename", "realpath", "readlink",
    "git add", "git mv", "git rm", "git commit", "git checkout", "git switch",
    "git merge", "git rebase", "git push", "git pull", "git fetch", "git stash",
    "git reset", "git restore", "git apply", "git cherry-pick", "git init", "git clone",
    "npm run", "npm test", "npm start", "npm install", "npm ci", "npm build",
    "pnpm", "yarn", "cargo test", "cargo build", "cargo check",
    "make", "just", "nix flake", "nix build", "nix develop", "nix shell",
    "nixos-rebuild", "home-manager", "tsc", "tsx",
  ],
  unsafePatterns: [
    // pi-sandbox already blocks most of these via allowWrite/denyWrite; this
    // list only forces a prompt (or plan-mode block) for high-signal cases.
    "rm -rf", "rm -fr", "sudo", "chmod 777", "docker system prune",
    "git reset --hard", "git push --force", "git push -f", "shutdown", "reboot",
  ],
};

// Split compound commands on shell operators so `cd x && rm y` is not judged
// by its `cd` prefix alone. Every segment must be classified. No single `|`
// here: it appears inside quoted regex/string args (e.g. `rg "a|b"`) and would
// split those into bogus non-command fragments.
const SEGMENT_SPLIT = /&&|\|\||;|\n/;

function matchesCommand(segment: string, entry: string): boolean {
  return segment === entry || segment.startsWith(entry + " ");
}

function loadBashConfig(): BashConfig {
  try {
    const configPath = join(getAgentDir(), "pledit.json");
    if (!existsSync(configPath)) return DEFAULT_BASH;
    const parsed: unknown = JSON.parse(readFileSync(configPath, "utf-8"));
    const record = (parsed ?? {}) as Record<string, unknown>;
    const list = (key: keyof BashConfig): string[] => {
      const value = record[key];
      return Array.isArray(value) && value.every((item) => typeof item === "string")
        ? (value as string[])
        : DEFAULT_BASH[key];
    };
    return { readonlyBash: list("readonlyBash"), safeBash: list("safeBash"), unsafePatterns: list("unsafePatterns") };
  } catch {
    return DEFAULT_BASH;
  }
}

function classifyBash(command: string, cfg: BashConfig): BashClass {
  const segments = command
    .split(SEGMENT_SPLIT)
    .map((s) => s.trim())
    .filter((s) => s !== "");
  if (segments.length === 0) return "readonly";

  // unsafePatterns override both lists: check first so `rm -rf` is not rescued
  // by the `rm ` safe entry.
  for (const seg of segments) {
    for (const pattern of cfg.unsafePatterns) {
      if (seg.includes(pattern)) return "unsafe";
    }
  }
  if (segments.every((seg) => cfg.readonlyBash.some((e) => matchesCommand(seg, e)))) {
    return "readonly";
  }
  const safeOrReadonly = [...cfg.readonlyBash, ...cfg.safeBash];
  if (segments.every((seg) => safeOrReadonly.some((e) => matchesCommand(seg, e)))) {
    return "safe";
  }
  return "unsafe";
}

type Mode = "auto" | "manual" | "plan";

const MODES: Mode[] = ["auto", "manual", "plan"];

interface ModeState {
  mode: Mode;
}

// One-line steering hint per mode, injected into the system prompt and swapped
// out on mode change. Real enforcement lives in the tool-call gate below; these
// only prime the model to behave consistently with the active mode.
const MODE_GUIDELINES: Record<Mode, string> = {
  auto: "Auto mode: apply edits and safe commands automatically.",
  manual: "Manual mode: each edit requires approval; state what you intend to change before editing.",
  plan: "Plan mode: read-only. Investigate the codebase and produce a structured implementation plan as your final response. Do not call write, edit, or non-read-only bash.",
};

function truncate(text: string, maxLines: number): string {
  const lines = String(text).split("\n");
  if (lines.length <= maxLines) return String(text);
  return lines.slice(0, maxLines).join("\n") + "\n…";
}

// Syntax-highlight a code snippet for the approval preview. Falls back to plain
// text when no language is known or highlighting throws, so the prompt never breaks.
function colorize(code: string, lang: string | undefined, maxLines: number): string {
  const text = truncate(code, maxLines);
  if (!lang) return text;
  try {
    return highlightCode(text, lang).join("\n");
  } catch {
    return text;
  }
}

function describeEdit(input: Record<string, unknown>): string {
  if (typeof input.path === "string") return input.path;
  return "(unknown path)";
}

function formatEdit(toolName: string, input: Record<string, unknown>): string {
  if (toolName === "bash") {
    return `command:\n${colorize(String(input.command ?? ""), "bash", 30)}`;
  }
  if (toolName === "write") {
    const path = describeEdit(input);
    return `path: ${path}\n\n${colorize(String(input.content ?? ""), getLanguageFromPath(path), 40)}`;
  }
  // edit: { path, edits: [{ oldText, newText }] }
  const path = describeEdit(input);
  const edits = Array.isArray(input.edits) ? (input.edits as Array<Record<string, unknown>>) : [];
  const lang = getLanguageFromPath(path);
  const parts = edits.map((e, i) => {
    const oldText = colorize(String(e.oldText ?? ""), lang, 20);
    const newText = colorize(String(e.newText ?? ""), lang, 20);
    return `#${i + 1}\n- ${oldText}\n+ ${newText}`;
  });
  return `path: ${path}\n\n${parts.join("\n\n") || "(no diff)"}`;
}

type ApprovalAction = "approve" | "reject" | "cancel";

interface ApprovalResult {
  action: ApprovalAction;
  note?: string;
}

const APPROVAL_OPTIONS: { label: string; key: string; action: ApprovalAction }[] = [
  { label: "Approve", key: "1", action: "approve" },
  { label: "Reject", key: "2", action: "reject" },
];

function showApprovalPrompt(
  ctx: ExtensionContext,
  heading: string,
  body: string,
): Promise<ApprovalResult | undefined> {
  return ctx.ui.custom<ApprovalResult>((tui, theme, _kb, done) => {
    const input = new Input();
    let selectedIndex = 0;
    let editing = false;
    let componentFocused = false;
    const bodyLines = body.split("\n");

    const selectedOption = (): (typeof APPROVAL_OPTIONS)[number] => APPROVAL_OPTIONS[selectedIndex]!;
    const isEditable = (option: (typeof APPROVAL_OPTIONS)[number]): boolean =>
      option.action === "approve" || option.action === "reject";
    const readNote = (): string | undefined => {
      const value = input.getValue().trim();
      return value.length > 0 ? value : undefined;
    };
    const updateFocus = (): void => {
      input.focused = componentFocused && editing;
    };

    return {
      get focused(): boolean {
        return componentFocused;
      },
      set focused(value: boolean) {
        componentFocused = value;
        updateFocus();
      },
      render(width: number): string[] {
        const out: string[] = [truncateToWidth(theme.fg("warning", heading), width), ""];
        for (const line of bodyLines) out.push(truncateToWidth(line, width));
        out.push("");
        for (let i = 0; i < APPROVAL_OPTIONS.length; i++) {
          const option = APPROVAL_OPTIONS[i]!;
          const isSelected = i === selectedIndex;
          const prefix = isSelected ? " → " : "   ";
          const keyHint = theme.fg("accent", `[${option.key}]`);
          let label = option.label;
          if (editing && isSelected && isEditable(option)) {
            const base = `${prefix}${keyHint} ${label} `;
            const inputWidth = Math.max(1, width - visibleWidth(base));
            label += `${theme.fg("accent", input.render(inputWidth)[0] ?? "")}`;
          }
          out.push(truncateToWidth(`${prefix}${keyHint} ${label}`, width));
        }
        out.push("");
        out.push(
          truncateToWidth(
            theme.fg(
              "dim",
              editing
                ? "enter confirm · esc discard note · ↑↓ move selection"
                : "↑↓ navigate · 1/2 select · tab add note · enter confirm · esc cancel",
            ),
            width,
          ),
        );
        return out;
      },
      handleInput(data: string): void {
        if (matchesKey(data, Key.ctrl("c"))) {
          done({ action: "cancel" });
          return;
        }
        if (editing) {
          if (matchesKey(data, Key.escape)) {
            editing = false;
            updateFocus();
            tui.requestRender();
            return;
          }
          if (matchesKey(data, Key.enter)) {
            done({ action: selectedOption().action, note: readNote() });
            return;
          }
          if (matchesKey(data, Key.up) || matchesKey(data, Key.down)) {
            const delta = matchesKey(data, Key.up) ? -1 : 1;
            selectedIndex = Math.max(0, Math.min(APPROVAL_OPTIONS.length - 1, selectedIndex + delta));
            editing = false;
            updateFocus();
            tui.requestRender();
            return;
          }
          input.handleInput(data);
          tui.requestRender();
          return;
        }
        if (matchesKey(data, Key.escape)) {
          done({ action: "cancel" });
          return;
        }
        if (matchesKey(data, Key.tab)) {
          if (isEditable(selectedOption())) {
            editing = true;
            updateFocus();
            tui.requestRender();
          }
          return;
        }
        if (matchesKey(data, Key.enter)) {
          done({ action: selectedOption().action });
          return;
        }
        if (matchesKey(data, Key.up)) {
          selectedIndex = Math.max(0, selectedIndex - 1);
          tui.requestRender();
          return;
        }
        if (matchesKey(data, Key.down)) {
          selectedIndex = Math.min(APPROVAL_OPTIONS.length - 1, selectedIndex + 1);
          tui.requestRender();
          return;
        }
        for (const option of APPROVAL_OPTIONS) {
          if (data === option.key) {
            done({ action: option.action });
            return;
          }
        }
      },
      invalidate(): void {
        input.invalidate();
      },
      dispose(): void {},
    };
  });
}

// Default mode for a new interactive session: manual (approve every edit).
// Headless runs always enforce auto via effectiveMode below. CLI override:
// PI_APPROVAL_MODE=auto pi (or =plan).
const envMode = process.env.PI_APPROVAL_MODE;
let mode: Mode =
  envMode === "auto" || envMode === "manual" || envMode === "plan" ? envMode : "manual";

// Headless runs share this module's state across sessions but have no UI to
// answer a manual/plan prompt: spawned agents (pi-subagents bind with
// "print"), `pi -p`, `--mode rpc`, and `--mode json` always enforce auto,
// regardless of the interactive session's mode. Only the interactive TUI
// honors the selected mode.
function effectiveMode(ctx: ExtensionContext): Mode {
  return ctx.mode === "tui" ? mode : "auto";
}

export default function approvalModes(pi: ExtensionAPI): void {
  const bash = loadBashConfig();

  // Notes typed on an approval, keyed by toolCallId, injected into the tool result.
  const pendingNotes = new Map<string, string>();

  const statusKey = "approval-mode";

  function updateStatus(ctx: ExtensionContext): void {
    const label = mode;
    const color =
      mode === "auto"
        ? ctx.ui.theme.fg("error", label)
        : mode === "plan"
          ? ctx.ui.theme.fg("accent", label)
          : ctx.ui.theme.fg("warning", label);
    ctx.ui.setStatus(statusKey, color);
  }

  function persist(): void {
    pi.appendEntry(statusKey, { mode });
  }

  function setMode(next: Mode, ctx: ExtensionContext): void {
    mode = next;
    updateStatus(ctx);
    persist();
    const message =
      next === "auto"
        ? "Auto mode: edits and safe commands apply automatically"
        : next === "manual"
          ? "Manual mode: approve each edit before it applies"
          : "Plan mode: read-only; produce a plan instead of editing";
    ctx.ui.notify(message, "info");
  }

  function cycleMode(ctx: ExtensionContext): void {
    setMode(MODES[(MODES.indexOf(mode) + 1) % MODES.length]!, ctx);
  }

  pi.registerCommand("manual", {
    description: "Manual mode: approve/reject every file edit",
    handler: async (_args, ctx) => setMode("manual", ctx),
  });

  pi.registerCommand("auto", {
    description: "Auto mode: apply file edits and safe commands automatically",
    handler: async (_args, ctx) => setMode("auto", ctx),
  });

  pi.registerCommand("plan", {
    description: "Plan mode: read-only analysis that produces a plan",
    handler: async (_args, ctx) => setMode("plan", ctx),
  });

  pi.registerShortcut("shift+tab", {
    description: "Cycle auto/manual/plan approval mode",
    handler: async (ctx) => cycleMode(ctx),
  });

  // Steer the model with the active mode's hint. Toggling updates `mode`; the
  // next turn swaps the current guideline into the system prompt, dropping any
  // stale mode hint left over from a previous cycle.
  pi.on("before_agent_start", async (event, ctx) => {
    const opts = event.systemPromptOptions;
    if (!Array.isArray(opts.promptGuidelines)) {
      opts.promptGuidelines = [];
    }
    const guidelines = opts.promptGuidelines;
    for (const stale of Object.values(MODE_GUIDELINES)) {
      const index = guidelines.indexOf(stale);
      if (index !== -1) guidelines.splice(index, 1);
    }
    guidelines.push(MODE_GUIDELINES[effectiveMode(ctx)]);
  });

  pi.on("session_start", async (_event, ctx) => {
    // Only the interactive session restores (and shows) its saved mode. A
    // headless run or child session's entries must never flip the shared
    // module state, and headless enforcement is auto regardless (effectiveMode).
    if (ctx.mode !== "tui") return;
    for (const entry of ctx.sessionManager.getEntries()) {
      if (entry.type === "custom" && entry.customType === statusKey) {
        const data = entry.data as ModeState | { manual?: boolean } | undefined;
        if (data && "mode" in data && (data.mode === "auto" || data.mode === "manual" || data.mode === "plan")) {
          mode = (data as ModeState).mode;
        } else if (data && "manual" in data && typeof (data as { manual?: boolean }).manual === "boolean") {
          // Backward compat with the old `{ manual: boolean }` entries.
          mode = (data as { manual: boolean }).manual ? "manual" : "auto";
        }
      }
    }
    updateStatus(ctx);
  });

  pi.on("tool_call", async (event, ctx) => {
    if (!WRITE_TOOLS.has(event.toolName)) return undefined;

    let cls: BashClass | undefined;
    if (event.toolName === "bash") {
      cls = classifyBash(String(event.input.command ?? ""), bash);
      if (cls === "readonly") return undefined;
    }

    const effective = effectiveMode(ctx);
    let decision: "allow" | "prompt" | "block";
    if (event.toolName === "bash") {
      if (effective === "plan") decision = "block";
      else if (effective === "manual") decision = "prompt";
      else decision = cls === "safe" ? "allow" : "prompt";
    } else {
      // write/edit
      if (effective === "plan") decision = "block";
      else if (effective === "manual") decision = "prompt";
      else decision = "allow";
    }

    if (decision === "allow") return undefined;

    if (decision === "block") {
      return {
        block: true,
        reason: `Plan mode: ${event.toolName} blocked (read-only; produce a plan instead)`,
      };
    }

    if (!ctx.hasUI) {
      // Non-interactive (subagent): can't ask, so fail safe.
      return { block: true, reason: `${effective} mode: ${event.toolName} blocked (no UI to confirm)` };
    }

    const result = await showApprovalPrompt(
      ctx,
      `Approve ${event.toolName}?`,
      formatEdit(event.toolName, event.input as Record<string, unknown>),
    );
    const action = result?.action;
    const note = result?.note;

    if (action === undefined || action === "cancel") {
      return { block: true, reason: `${event.toolName} cancelled by user (${effective} mode)` };
    }
    if (action === "reject") {
      return { block: true, reason: note ? `${event.toolName} rejected: ${note}` : `${event.toolName} rejected by user (${effective} mode)` };
    }
    if (note) {
      pendingNotes.set(event.toolCallId, note);
    }
    return undefined;
  });

  pi.on("tool_result", async (event) => {
    const note = pendingNotes.get(event.toolCallId);
    if (note === undefined) return undefined;
    pendingNotes.delete(event.toolCallId);
    const noteBlock = { type: "text" as const, text: `\n[user note] ${note}` };
    return {
      content: Array.isArray(event.content) ? [...event.content, noteBlock] : [noteBlock],
    };
  });
}