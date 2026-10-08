/*
 * /commit-flash: stage all changes and commit with a conventional commit
 * message generated on a cheaper flash model. Falls back to the session's
 * current model when the flash model is unavailable.
 *
 * The commit logic is inlined here (instead of invoking the commit skill)
 * so it runs end to end inside the command handler on one model call.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const FLASH = { provider: "openrouter", modelId: "deepseek/deepseek-v4-flash-0731" };

const MESSAGE_PROMPT = [
    "Write a conventional commit message for the diff below.",
    "",
    "Format: <type>(<scope>): <short description>",
    "Types: feat, fix, refactor, chore, docs, test, perf, style, ci.",
    "Rules: imperative mood, lowercase after the colon, no trailing period,",
    "subject at most 72 characters. Be specific about what changed, not that",
    "something changed. Scope is optional and one short word.",
    "Use a multi-line body only when the change genuinely requires explanation.",
    "Output ONLY the commit message. No commentary, no code fences.",
    "",
    "<diff>",
].join("\n");

function textOf(content: unknown): string {
    const parts = Array.isArray(content) ? content : [{ type: "text", text: String(content) }];
    return parts
        .filter((c): c is { type: "text"; text: string } => c.type === "text")
        .map((c) => c.text)
        .join("\n")
        .replace(/^```[a-z]*\s*/i, "")
        .replace(/\s*```\s*$/, "")
        .trim();
}

export default function (pi: ExtensionAPI) {
    pi.registerCommand("commit-flash", {
        description: "Commit all changes with a conventional commit message (flash model)",
        async handler(_args, ctx) {
            const notify = (msg: string, level: "info" | "warning" | "error") => {
                if (ctx.hasUI) ctx.ui.notify(msg, level);
            };

            const status = await pi.exec("git", ["status", "--porcelain"]);
            if (status.code !== 0) {
                notify("Not a git repository", "warning");
                return;
            }
            if (!status.stdout.trim()) {
                notify("Nothing to commit", "info");
                return;
            }

            const add = await pi.exec("git", ["add", "-A"]);
            if (add.code !== 0) {
                notify(`git add failed: ${add.stderr.trim() || "unknown error"}`, "error");
                return;
            }

            const diff = await pi.exec("git", ["diff", "--cached"]);
            const diffText = diff.stdout.trim() || status.stdout.trim();

            const flash = ctx.modelRegistry.find(FLASH.provider, FLASH.modelId);
            const model = flash && ctx.modelRegistry.hasConfiguredAuth(flash) ? flash : ctx.model;

            notify("Generating commit message...", "info");

            let message: string;
            try {
                const response = await ctx.modelRegistry.complete(
                    model,
                    {
                        messages: [
                            {
                                role: "user" as const,
                                content: [{ type: "text" as const, text: MESSAGE_PROMPT + "\n" + diffText + "\n</diff>" }],
                                timestamp: Date.now(),
                            },
                        ],
                    },
                    { maxTokens: 512, cacheRetention: "none", sessionId: ctx.sessionManager.getSessionId() },
                );
                message = textOf(response.content);
            } catch (error) {
                notify(`Commit message failed: ${error instanceof Error ? error.message : String(error)}`, "error");
                return;
            }

            if (!message) {
                notify("Empty commit message", "error");
                return;
            }

            const commit = await pi.exec("git", ["commit", "-m", message]);
            if (commit.code !== 0) {
                notify(`git commit failed: ${commit.stderr.trim() || "unknown error"}`, "error");
                return;
            }

            notify(`Committed: ${message.split("\n")[0]}`, "info");
        },
    });
}