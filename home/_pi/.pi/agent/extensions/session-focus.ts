/*
 * Generates a few-word description of what this session is working on, shown
 * in the footer, and (if the session has no name yet) used as its name so
 * /resume lists something meaningful. Runs once at session start, then
 * refreshes every REFRESH_EVERY_TURNS turns, not every prompt, so the extra
 * model call costs almost nothing.
 *
 * The name is also mirrored into the tmux window title (the tab name) on each
 * refresh. When pi is not running inside tmux this is a no-op.
 */
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

import { decide } from "./lib/jev";
import { execFile } from "node:child_process";

const REFRESH_EVERY_TURNS = 3;

/* Only regenerate when Jev is confident the title no longer fits. A higher bar
 * here flaps on borderline titles (e.g. p=0.67) and toggles between synonyms.
 */

const TITLE_ACCURATE_THRESHOLD = 0.4;

/* Small window keeps the title tracking the *recent* topic. A large window
 * dilutes new topics with old ones, so the title lags and Jev always says stale.
 */
const MAX_HISTORY_CHARS = 3000;
const MAX_TOPIC_WORDS = 3;

/* Mirror the pi session name into the tmux window title (the tab name).
 * rename-window defaults to the *focused* window, so target pi's own pane via
 * TMUX_PANE. process.env.TMUX is only set inside tmux, so outside it this is
 * a no-op (and a missing TMUX_PANE is treated the same way, rather than
 * renaming the wrong window).
 */
function renameTmuxWindow(name: string) {
    const pane = process.env.TMUX_PANE;
    if (!process.env.TMUX || !pane || !name) return;
    execFile(
        "tmux",
        ["display-message", "-p", "-F", "#{window_id}", "-t", pane],
        (_err, stdout) => {
            const window = stdout.trim();
            if (window) execFile("tmux", ["rename-window", "-t", window, name], () => {});
        }
    );
}

type Entry = { type?: string; message?: { role?: string; content?: unknown } };

export function extractText(content: unknown): string {
    if (typeof content === "string") return content;
    if (!Array.isArray(content)) return "";
    return content
        .map((part) => {
            if (!part || typeof part !== "object") return "";
            const block = part as { type?: string; text?: string };
            return block.type === "text" && typeof block.text === "string" ? block.text : "";
        })
        .filter(Boolean)
        .join("\n");
}

export function buildFocusText(entries: Entry[]): string {
    const lines: string[] = [];
    for (const entry of entries) {
        if (entry.type !== "message" || !entry.message?.role) continue;
        const role = entry.message.role;
        if (role !== "user" && role !== "assistant") continue;
        const text = extractText(entry.message.content).trim();
        if (text) lines.push(`${role === "user" ? "User" : "Assistant"}: ${text}`);
    }
    return lines.join("\n").slice(-MAX_HISTORY_CHARS);
}

async function titleStillAccurate(title: string, history: string): Promise<boolean> {
    const state = { title, conversation: history };
    const questions = {
        title_accurate: {
            type: "noul" as const,
            instructions:
                "Does the current title accurately describe the most recent topic of this coding session?",
            criteria: {
                true: "The title accurately captures the most recent topic of discussion.",
                false: "The conversation has moved to a different topic, or the title is too vague or wrong.",
            },
        },
    };
    try {
        const { answers } = await decide(state, questions);

        const answer = answers.title_accurate;
        if (answer?.type === "noul") {
            return answer.noul >= TITLE_ACCURATE_THRESHOLD;
        }

        console.error("[session-focus] jev: unexpected answer", JSON.stringify(answer));
        return false;
    } catch {
        // Jev failure (timeout, HTTP error) is non-fatal: fall through and
        // regenerate the title. Silent by design so it never reaches the prompt.
        return false;
    }
}

async function generateTopic(ctx: ExtensionContext, pi: ExtensionAPI): Promise<void> {
    const history = buildFocusText(ctx.sessionManager.getBranch());
    if (!history.trim()) {
        return;
    }

    const current = pi.getSessionName();
    if (current && (await titleStillAccurate(current, history))) {
        return;
    }

    const model = ctx.model;
    if (!model || !ctx.modelRegistry.hasConfiguredAuth(model)) {
        console.error("[session-focus] no authed model:", model?.id ?? "none");
        return;
    }

    const prompt = [
        `Write a specific 2-${MAX_TOPIC_WORDS} word title for the MOST RECENT topic of this coding session. Include the subject and its focus (e.g. "tiger conservation", not "tiger"). The last messages matter most; ignore older, completed topics.`,
        "Reply with only the title: no punctuation, no quotes, no explanation.",
        "",
        "<conversation>",
        history,
        "</conversation>",
    ].join("\n");

    const response = await ctx.modelRegistry.complete(
        model,
        {
            messages: [
                {
                    role: "user" as const,
                    content: [{ type: "text" as const, text: prompt }],
                    timestamp: Date.now(),
                },
            ],
        },
        {
            maxTokens: 256,
            // No reasoningEffort: for deepseek (thinkingFormat "deepseek") this sends
            // thinking: { type: "disabled" }, so the title call runs without reasoning.
            sessionId: ctx.sessionManager.getSessionId(),
        }
    );

    const text = response.content
        .filter((c): c is { type: "text"; text: string } => c.type === "text")
        .map((c) => c.text)
        .join(" ");
    const thinking = response.content
        .filter((c): c is { type: "thinking"; thinking: string } => c.type === "thinking")
        .map((c) => c.thinking)
        .join(" ");
    const topic = (text || thinking).replace(/\s+/g, " ").trim().toLowerCase();
    if (!topic) {
        console.error(
            "[session-focus] empty topic; content types:",
            JSON.stringify(response.content.map((c) => (c as { type?: string }).type))
        );
        return;
    }

    // Keep the footer title current; this overrides any manually-set name.
    pi.setSessionName(topic);
}

export default function sessionFocus(pi: ExtensionAPI) {
    let turns = 0;
    let running = false;

    const refresh = (ctx: ExtensionContext): void => {
        if (running) return;
        running = true;
        generateTopic(ctx, pi)
            .catch((error) => {
                console.error("[session-focus] topic generation failed:", error instanceof Error ? error.message : String(error));
            })
            .finally(() => {
                renameTmuxWindow(pi.getSessionName());
                running = false;
            });
    };

    pi.on("session_start", async (_event, ctx) => {
        refresh(ctx);
    });

    pi.on("turn_end", async (_event, ctx) => {
        turns += 1;
        if (turns === 1 || turns % REFRESH_EVERY_TURNS === 0) refresh(ctx);
    });
}

if (process.env.SESSION_FOCUS_SELFTEST) {
    const sample: Entry[] = [
        {
            type: "message",
            message: { role: "user", content: "Refactor the auth module to use JWT" },
        },
        {
            type: "message",
            message: {
                role: "assistant",
                content: [
                    { type: "text", text: "On it" },
                    { type: "toolCall", name: "read", arguments: {} },
                ],
            },
        },
        { type: "message", message: { role: "system", content: "" } },
    ];
    const text = buildFocusText(sample);
    const ok =
        text.includes("Refactor the auth module to use JWT") &&
        text.includes("Assistant: On it") &&
        !text.includes("System");
    if (!ok) {
        console.error("SELFTEST FAILED:\n" + text);
        process.exit(1);
    }
    console.log("session-focus selftest ok");
}
