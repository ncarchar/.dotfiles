/*
 * Approval Modes Extension - Claude Code-style plan/manual/auto edit approvals.
 *
 * /plan    - read-only: write/edit and non-read-only bash are blocked, and the
 *            model is steered to produce a structured implementation plan.
 * /manual  - each write/edit (and non-read-only bash) prompts Approve/Reject.
 * /auto    - write/edit and known-safe bash apply automatically (default).
 * shift+tab - cycles auto -> manual -> plan -> auto.
 *
 * Bash classification (readonlyBash / safeBash / unsafePatterns) loads from
 * ~/.pi/agent/bash-classification.json.
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

const WRITE_TOOLS = new Set<string>(["edit", "write", "bash"]);

type BashClass = "readonly" | "safe" | "unsafe";

interface BashConfig {
    readonlyBash: string[];
    safeBash: string[];
    unsafePatterns: string[];
}

/* Empty fallbacks: ~/.pi/agent/bash-classification.json holds the live lists.
 * When it is missing or malformed, empty lists classify every non-empty command
 * as unsafe, so it prompts rather than runs with no guardrails.
 */
const DEFAULT_BASH: BashConfig = {
    readonlyBash: [],
    safeBash: [],
    unsafePatterns: [],
};

/* Strip leading `VAR=value ` env assignments from a command segment. */
const ENV_PREFIX = /^(?:[A-Za-z_][A-Za-z0-9_]*=[^\s]+\s+)+/;

/* Split a command on shell operators (`&&`, `||`, `;`) and top-level newlines,
 * but not inside quotes. A multi-line `jq`/`awk` program is one segment, not a
 * pile of continuation lines (`[`, `test(`) that would classify as unsafe.
 */
function splitSegments(command: string): string[] {
    const segments: string[] = [];
    let current = "";
    let quote: "'" | '"' | null = null;
    for (let i = 0; i < command.length; i++) {
        const ch = command[i]!;
        if (quote !== null) {
            current += ch;
            if (ch === quote) quote = null;
            continue;
        }
        if (ch === "'" || ch === '"') {
            quote = ch;
            current += ch;
            continue;
        }
        const two = command.slice(i, i + 2);
        if (two === "&&" || two === "||") {
            const seg = current.trim();
            if (seg !== "") segments.push(seg);
            current = "";
            i++;
            continue;
        }
        if (ch === ";" || ch === "\n") {
            const seg = current.trim();
            if (seg !== "") segments.push(seg);
            current = "";
            continue;
        }
        current += ch;
    }
    const last = current.trim();
    if (last !== "") segments.push(last);
    return segments;
}

function matchesCommand(segment: string, entry: string): boolean {
    const seg = segment.replace(ENV_PREFIX, "");
    return seg === entry || seg.startsWith(entry + " ");
}

function loadBashConfig(): BashConfig {
    try {
        const configPath = join(getAgentDir(), "bash-classification.json");
        if (!existsSync(configPath)) return DEFAULT_BASH;
        const parsed: unknown = JSON.parse(readFileSync(configPath, "utf-8"));
        const record = (parsed ?? {}) as Record<string, unknown>;
        const list = (key: keyof BashConfig): string[] => {
            const value = record[key];
            return Array.isArray(value) && value.every((item) => typeof item === "string")
                ? (value as string[])
                : DEFAULT_BASH[key];
        };
        return {
            readonlyBash: list("readonlyBash"),
            safeBash: list("safeBash"),
            unsafePatterns: list("unsafePatterns"),
        };
    } catch {
        return DEFAULT_BASH;
    }
}

interface BashClassification {
    cls: BashClass;
    command?: string;
}

function commandName(segment: string): string {
    const rest = segment.replace(ENV_PREFIX, "");
    const word = rest.split(/\s+/)[0] ?? "";
    return word.split("/").pop() || "command";
}

function classifyBash(command: string, cfg: BashConfig): BashClassification {
    const segments = splitSegments(command);
    if (segments.length === 0) return { cls: "readonly" };

    const isReadonly = (seg: string): boolean =>
        cfg.readonlyBash.some((e) => matchesCommand(seg, e));
    const isSafeOrReadonly = (seg: string): boolean =>
        isReadonly(seg) || cfg.safeBash.some((e) => matchesCommand(seg, e));

    for (const seg of segments) {
        if (cfg.unsafePatterns.some((p) => seg.includes(p))) {
            return { cls: "unsafe", command: commandName(seg) };
        }
    }
    if (segments.every(isReadonly)) return { cls: "readonly" };
    if (segments.every(isSafeOrReadonly)) {
        const seg = segments.find((s) => !isReadonly(s));
        return { cls: "safe", command: seg ? commandName(seg) : undefined };
    }
    const seg = segments.find((s) => !isSafeOrReadonly(s));
    return { cls: "unsafe", command: seg ? commandName(seg) : undefined };
}

type Mode = "auto" | "manual" | "plan";

const MODES: Mode[] = ["auto", "manual", "plan"];

interface ModeState {
    mode: Mode;
}

const MODE_GUIDELINES: Record<Mode, string> = {
    auto: "Auto mode: apply edits and safe commands automatically.",
    manual: "Manual mode: each edit requires approval; state what you intend to change before editing.",
    plan: "Plan mode: read-only. Investigate the codebase and produce a structured implementation plan as your final response. Do not call write, edit, or non-read-only bash.",
};

/* Short human-facing summaries, distinct from the long model guidelines above. */
const MODE_SUMMARIES: Record<Mode, string> = {
    auto: "edits and safe commands apply automatically",
    manual: "approve each edit before it applies",
    plan: "read-only; produce a plan instead of editing",
};

function truncate(text: string, maxLines: number): string {
    const lines = String(text).split("\n");
    if (lines.length <= maxLines) return String(text);
    return lines.slice(0, maxLines).join("\n") + "\n…";
}

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
    reason: string
): Promise<ApprovalResult | undefined> {
    return ctx.ui.custom<ApprovalResult>((tui, theme, _kb, done) => {
        const input = new Input();
        let selectedIndex = 0;
        let editing = false;
        let componentFocused = false;
        const bodyLines = body.split("\n");

        const selectedOption = (): (typeof APPROVAL_OPTIONS)[number] =>
            APPROVAL_OPTIONS[selectedIndex]!;
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
                const out: string[] = [
                    truncateToWidth(theme.fg("warning", heading), width),
                    truncateToWidth(theme.fg("dim", `Reason: ${reason}`), width),
                    "",
                ];
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
                                : "↑↓ navigate · 1/2 select · tab add note · enter confirm · esc cancel"
                        ),
                        width
                    )
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
                        selectedIndex = Math.max(
                            0,
                            Math.min(APPROVAL_OPTIONS.length - 1, selectedIndex + delta)
                        );
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

const envMode = process.env.PI_APPROVAL_MODE;
let mode: Mode =
    envMode === "auto" || envMode === "manual" || envMode === "plan" ? envMode : "manual";

function effectiveMode(ctx: ExtensionContext): Mode {
    return ctx.mode === "tui" ? mode : "auto";
}

export default function approvalModes(pi: ExtensionAPI): void {
    const bash = loadBashConfig();

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
        ctx.ui.notify(`${next} mode: ${MODE_SUMMARIES[next]}`, "info");
    }

    function cycleMode(ctx: ExtensionContext): void {
        setMode(MODES[(MODES.indexOf(mode) + 1) % MODES.length]!, ctx);
    }

    for (const m of MODES) {
        pi.registerCommand(m, {
            description: `${m} mode: ${MODE_SUMMARIES[m]}`,
            handler: async (_args, ctx) => setMode(m, ctx),
        });
    }

    pi.registerShortcut("shift+tab", {
        description: "Cycle auto/manual/plan approval mode",
        handler: async (ctx) => cycleMode(ctx),
    });

    /* Steer the model with the active mode's hint. Toggling updates `mode`; the
     * next turn swaps the current guideline into the system prompt, dropping any
     * stale mode hint left over from a previous cycle.
     */
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
        /* Only the interactive session restores (and shows) its saved mode. A
         * headless run or child session's entries must never flip the shared
         * module state, and headless enforcement is auto regardless (effectiveMode).
         */
        if (ctx.mode !== "tui") return;
        for (const entry of ctx.sessionManager.getEntries()) {
            if (entry.type === "custom" && entry.customType === statusKey) {
                const data = entry.data as ModeState | undefined;
                if (
                    data &&
                    (data.mode === "auto" || data.mode === "manual" || data.mode === "plan")
                ) {
                    mode = data.mode;
                }
            }
        }
        updateStatus(ctx);
    });

    pi.on("tool_call", async (event, ctx) => {
        if (!WRITE_TOOLS.has(event.toolName)) return undefined;

        let classification: BashClassification | undefined;
        if (event.toolName === "bash") {
            classification = classifyBash(String(event.input.command ?? ""), bash);
            if (classification.cls === "readonly") return undefined;
        }

        const effective = effectiveMode(ctx);
        let decision: "allow" | "prompt" | "block";
        if (event.toolName === "bash") {
            if (effective === "plan") decision = "block";
            else if (effective === "manual") decision = "prompt";
            else decision = classification?.cls === "safe" ? "allow" : "prompt";
        } else {
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
            return {
                block: true,
                reason: `${effective} mode: ${event.toolName} blocked (no UI to confirm)`,
            };
        }

        const flaggedCmd = classification?.command ?? "command";
        const reason =
            event.toolName === "bash"
                ? effective === "manual"
                    ? `manual mode: \`${flaggedCmd}\` requires approval`
                    : `auto mode: \`${flaggedCmd}\` classified unsafe`
                : "manual mode requires approval for file edits";

        const result = await showApprovalPrompt(
            ctx,
            `Approve ${event.toolName}?`,
            formatEdit(event.toolName, event.input as Record<string, unknown>),
            reason
        );
        const action = result?.action;
        const note = result?.note;

        if (action === undefined || action === "cancel") {
            return {
                block: true,
                reason: `${event.toolName} cancelled by user (${effective} mode)`,
            };
        }
        if (action === "reject") {
            return {
                block: true,
                reason: note
                    ? `${event.toolName} rejected: ${note}`
                    : `${event.toolName} rejected by user (${effective} mode)`,
            };
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
