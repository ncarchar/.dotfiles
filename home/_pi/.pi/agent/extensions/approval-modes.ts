/*
 * Bash approval guard - confirm destructive commands before they run.
 *
 * edit/write always apply. A bash command runs too, unless it matches one of
 * UNSAFE_PATTERNS (lib/unsafe-bash.ts). That opens an approve/reject prompt;
 * both choices accept a note, which is attached to the tool result.
 *
 * This is a guard, not a sandbox. pi-sandbox is the real OS-level boundary
 * (bwrap blocks writes outside allowWrite and blocks unlisted domains). This
 * catches the high-signal destructive commands the sandbox would otherwise
 * allow: repo writes such as `git reset --hard`, and pushes over github.com.
 */

import {
    highlightCode,
    type ExtensionAPI,
    type ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import { Input, Key, matchesKey, truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";
import { isUnsafe } from "./lib/unsafe-bash";

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

function formatBash(command: string): string {
    return `command:\n${colorize(command, "bash", 30)}`;
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

export default function bashApproval(pi: ExtensionAPI): void {
    const pendingNotes = new Map<string, string>();

    pi.on("tool_call", async (event, ctx) => {
        if (event.toolName !== "bash") return undefined;

        const command = String(event.input.command ?? "");
        const pattern = isUnsafe(command);
        if (pattern === undefined) return undefined;

        if (!ctx.hasUI) {
            return {
                block: true,
                reason: `bash blocked (no UI to confirm unsafe pattern \`${pattern}\`)`,
            };
        }

        const result = await showApprovalPrompt(
            ctx,
            "Approve bash command?",
            formatBash(command),
            `unsafe pattern: \`${pattern}\``
        );
        const action = result?.action;
        const note = result?.note;

        if (action === "approve") {
            if (note) {
                pendingNotes.set(event.toolCallId, note);
            }
            return undefined;
        }
        if (action === "reject") {
            return {
                block: true,
                reason: note ? `bash rejected: ${note}` : "bash rejected by user",
            };
        }
        return { block: true, reason: "bash cancelled by user" };
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
