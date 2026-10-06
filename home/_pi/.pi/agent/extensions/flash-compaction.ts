/*
 * Runs pi's auto-compaction summaries on a flash model instead of the main
 * conversation model. The main model's output pricing is the expensive part of
 * every compaction, so a flash model makes each summary far cheaper.
 *
 * Falls back to pi's default compactor whenever the flash model is missing,
 * unauthenticated, empty, or errors, so compaction never silently breaks.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { convertToLlm, serializeConversation } from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";

const COMPACT_MODEL = { provider: "openrouter", modelId: "deepseek/deepseek-v4-flash-0731" };

const SUMMARY_INSTRUCTIONS = [
    "Summarize this conversation into a structured summary. The summary replaces old history, so preserve everything needed to continue the work.",
    "",
    "Use this exact structure:",
    "## Goal",
    "## Constraints & Preferences",
    "## Progress",
    "## Key Decisions",
    "## Next Steps",
    "## Critical Context",
    "",
    "Rules:",
    "- Do NOT continue or respond to the conversation; only output the summary.",
    "- Keep concrete file paths, decisions, error messages, and state later work depends on.",
    "- Drop only what is clearly finished and irrelevant.",
].join("\n");

function computeFileLists(fileOps: {
    read: Set<string>;
    written: Set<string>;
    edited: Set<string>;
}) {
    const modified = new Set<string>([...fileOps.written, ...fileOps.edited]);
    const modifiedFiles = [...modified].sort();
    const readFiles = [...fileOps.read].filter((f) => !modified.has(f)).sort();
    return { readFiles, modifiedFiles };
}

interface FlashCompactionCost {
    cost: number | null;
    input: number;
    output: number;
}

export default function flashCompaction(pi: ExtensionAPI) {
    pi.registerEntryRenderer<FlashCompactionCost>("flash-compaction", (entry, _options, theme) => {
        const d = entry.data;
        if (!d) return undefined;
        const costLabel = d.cost != null ? `$${d.cost.toFixed(4)}` : "cost unavailable";
        const line = `${theme.fg("accent", "[flash compaction]")} ${theme.fg("muted", `${costLabel} (${d.input} in / ${d.output} out tokens)`)}`;
        return new Text(line, 0, 0);
    });

    pi.on("session_compact", (event) => {
        if (!event.fromExtension) return;
        const usage = event.compactionEntry.usage;
        pi.appendEntry<FlashCompactionCost>("flash-compaction", {
            cost: usage?.cost?.total ?? null,
            input: usage?.input ?? 0,
            output: usage?.output ?? 0,
        });
    });

    pi.on("session_before_compact", async (event, ctx) => {
        const { preparation, signal, customInstructions } = event;
        const { messagesToSummarize, turnPrefixMessages, tokensBefore, firstKeptEntryId, previousSummary } = preparation;

        if (messagesToSummarize.length === 0 && turnPrefixMessages.length === 0) {
            return;
        }

        const model = ctx.modelRegistry.find(COMPACT_MODEL.provider, COMPACT_MODEL.modelId);
        if (!model || !ctx.modelRegistry.hasConfiguredAuth(model)) {
            ctx.ui.notify(`Compaction model ${COMPACT_MODEL.modelId} unavailable, using default compactor`, "warning");
            return;
        }

        const allMessages = [...messagesToSummarize, ...turnPrefixMessages];
        const conversationText = serializeConversation(convertToLlm(allMessages));

        const parts = [SUMMARY_INSTRUCTIONS];
        if (previousSummary) {
            parts.push(`\n\nPrevious summary (update and merge it, do not lose its content):\n${previousSummary}`);
        }
        if (customInstructions) {
            parts.push(`\n\nFocus for this summary: ${customInstructions}`);
        }
        parts.push(`\n\n<conversation>\n${conversationText}\n</conversation>`);

        try {
            const response = await ctx.modelRegistry.complete(
                model,
                {
                    messages: [
                        { role: "user" as const, content: [{ type: "text" as const, text: parts.join("\n") }], timestamp: Date.now() },
                    ],
                },
                {
                    maxTokens: 8192,
                    signal,
                    cacheRetention: "none",
                    sessionId: ctx.sessionManager.getSessionId(),
                }
            );

            const summary = response.content
                .filter((c): c is { type: "text"; text: string } => c.type === "text")
                .map((c) => c.text)
                .join("\n")
                .trim();

            if (!summary) {
                ctx.ui.notify("Compaction summary empty, using default compactor", "warning");
                return;
            }

            return {
                compaction: {
                    summary,
                    firstKeptEntryId,
                    tokensBefore,
                    usage: response.usage,
                    details: computeFileLists(preparation.fileOps),
                },
            };
        } catch (error) {
            const message = error instanceof Error ? error.message : String(error);
            ctx.ui.notify(`Flash compaction failed (${message}), using default compactor`, "error");
            return;
        }
    });
}