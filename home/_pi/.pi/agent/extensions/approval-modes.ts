/**
 * Approval Modes Extension — Claude Code-style manual/auto edit approvals.
 *
 * /manual  — each file-mutating tool call (edit, write, or non-read-only bash)
 *            prompts you to Approve or Reject before it runs
 * /auto    — edits apply automatically (default)
 *           — shift+tab toggles between the two modes
 *
 * pi-sandbox constraints still apply underneath; this gate only adds a prompt on top.
 */

import { getLanguageFromPath, highlightCode, type ExtensionAPI, type ExtensionContext } from "@earendil-works/pi-coding-agent";
import { Input, Key, matchesKey, truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

// Built-in tools that mutate files. bash is gated except for obviously read-only commands.
const WRITE_TOOLS = new Set<string>(["edit", "write", "bash"]);

// ponytail: regex allowlist for read-only shell commands is a heuristic, not a sandbox.
// A command can slip through (e.g. `git diff > patch`) — pi-sandbox is the real guard.
// Anchor with ^ so compound commands (`a && rm x`) still prompt.
const READ_ONLY_BASH = [
	/^\s*cat\b/, /^\s*head\b/, /^\s*tail\b/, /^\s*less\b/, /^\s*more\b/, /^\s*grep\b/,
	/^\s*find\b/, /^\s*ls\b/, /^\s*pwd\b/, /^\s*cd\b/, /^\s*wc\b/, /^\s*sort\b/, /^\s*uniq\b/, /^\s*diff\b/,
	/^\s*file\b/, /^\s*stat\b/, /^\s*du\b/, /^\s*df\b/, /^\s*tree\b/, /^\s*which\b/, /^\s*type\b/,
	/^\s*env\b/, /^\s*printenv\b/, /^\s*uname\b/, /^\s*whoami\b/, /^\s*id\b/, /^\s*date\b/,
	/^\s*uptime\b/, /^\s*ps\b/, /^\s*rg\b/, /^\s*fd\b/, /^\s*bat\b/, /^\s*eza\b/, /^\s*jq\b/,
	/^\s*echo\b/, /^\s*printf\b/, /^\s*node\s+--version/,
	/^\s*git\s+(status|log|diff|show|remote|ls-)/i,
	/^\s*npm\s+(list|ls|view|info|search|outdated|audit)/i,
];

function isReadOnlyBash(command: string): boolean {
	return READ_ONLY_BASH.some((p) => p.test(command));
}

interface ModeState {
	manual: boolean;
}

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

export default function approvalModes(pi: ExtensionAPI): void {
	let manual = true;

	// Notes typed on an approval, keyed by toolCallId, injected into the tool result.
	const pendingNotes = new Map<string, string>();

	const statusKey = "approval-mode";

	function updateStatus(ctx: ExtensionContext): void {
		ctx.ui.setStatus(
			statusKey,
			manual ? ctx.ui.theme.fg("warning", "manual") : ctx.ui.theme.fg("muted", "auto"),
		);
	}

	function persist(): void {
		pi.appendEntry(statusKey, { manual });
	}

	function setMode(next: boolean, ctx: ExtensionContext): void {
		manual = next;
		updateStatus(ctx);
		persist();
		ctx.ui.notify(manual ? "Manual mode: approve each edit before it applies" : "Auto mode: edits apply automatically", "info");
	}

	pi.registerCommand("manual", {
		description: "Manual mode — approve/reject every file edit",
		handler: async (_args, ctx) => setMode(true, ctx),
	});

	pi.registerCommand("auto", {
		description: "Auto mode — apply file edits automatically",
		handler: async (_args, ctx) => setMode(false, ctx),
	});

	pi.registerShortcut("shift+tab", {
		description: "Toggle manual/auto approval mode",
		handler: async (ctx) => setMode(!manual, ctx),
	});

	pi.on("session_start", async (_event, ctx) => {
		for (const entry of ctx.sessionManager.getEntries()) {
			if (entry.type === "custom" && entry.customType === statusKey) {
				manual = (entry.data as ModeState | undefined)?.manual === true;
			}
		}
		updateStatus(ctx);
	});

	pi.on("tool_call", async (event, ctx) => {
		if (!manual || !WRITE_TOOLS.has(event.toolName)) return undefined;

		// Read-only bash runs without a prompt (checked before the no-UI guard).
		if (event.toolName === "bash" && isReadOnlyBash(String(event.input.command ?? ""))) {
			return undefined;
		}

		if (!ctx.hasUI) {
			// Non-interactive (print/json): can't ask, so fail safe.
			return { block: true, reason: `Manual mode: ${event.toolName} blocked (no UI to confirm)` };
		}

		const result = await showApprovalPrompt(
			ctx,
			`Approve ${event.toolName}?`,
			formatEdit(event.toolName, event.input as Record<string, unknown>),
		);
		const action = result?.action;
		const note = result?.note;

		if (action === undefined || action === "cancel") {
			return { block: true, reason: "Edit cancelled by user (manual mode)" };
		}
		if (action === "reject") {
			return { block: true, reason: note ? `Edit rejected: ${note}` : "Edit rejected by user (manual mode)" };
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
