/*
 * Generates a few-word description of what this session is working on, shown
 * in the footer, and (if the session has no name yet) used as its name so
 * /resume lists something meaningful. Runs once at session start, then
 * refreshes every REFRESH_EVERY_TURNS turns, not every prompt, so the extra
 * model call costs almost nothing.
 */
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const REFRESH_EVERY_TURNS = 3;
const MAX_HISTORY_CHARS = 5000;
const MAX_TOPIC_WORDS = 4;

const TOPIC_MODEL: { provider: string; modelId: string } | undefined = undefined;

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

async function generateTopic(ctx: ExtensionContext, pi: ExtensionAPI): Promise<void> {
    const history = buildFocusText(ctx.sessionManager.getBranch());
    if (!history.trim()) {
        console.error("[session-focus] no history yet");
        return;
    }

    const model = TOPIC_MODEL
        ? ctx.modelRegistry.find(TOPIC_MODEL.provider, TOPIC_MODEL.modelId)
        : ctx.model;
    if (!model || !ctx.modelRegistry.hasConfiguredAuth(model)) {
        ctx.ui?.notify(`session-focus: no authed model (${model?.id ?? "none"})`, "error");
        return;
    }

    const prompt = [
        `Write a title of at most ${MAX_TOPIC_WORDS} words describing what this coding session is focused on.`,
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
        ctx.ui?.notify("session-focus: model returned no title", "error");
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
                const message = error instanceof Error ? error.message : String(error);
                console.error("[session-focus] topic generation failed:", error);
                ctx.ui?.notify(`session-focus failed: ${message}`, "error");
            })
            .finally(() => {
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
