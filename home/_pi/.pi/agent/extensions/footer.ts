/*
 * Custom footer mirroring pi's built-in footer line-for-line, as a seam for
 * future changes. Data sources match the built-in footer:
 *   cwd/session/entries: ctx.sessionManager
 *   context usage:       ctx.getContextUsage()
 *   model/thinking:      ctx.model / pi.getThinkingLevel()
 *   branch/statuses:     footerData (getGitBranch/getExtensionStatuses/
 *                        getAvailableProviderCount/onBranchChange)
 *
 * Any extension can add a footer segment with ctx.ui.setStatus(key, text); it
 * renders on the last line sorted by key, so no change here is needed to add one.
 */

import { isAbsolute, relative, resolve, sep } from "node:path";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";
import type {
    ExtensionAPI,
    ExtensionContext,
    ReadonlyFooterDataProvider,
    Theme,
} from "@earendil-works/pi-coding-agent";

interface Totals {
    input: number;
    output: number;
    cacheRead: number;
    cacheWrite: number;
    cost: number;
}

interface UsageLike {
    input?: number;
    output?: number;
    cacheRead?: number;
    cacheWrite?: number;
    cost?: { total?: number };
}

function addUsage(totals: Totals, usage: UsageLike | null | undefined): void {
    if (!usage) return;
    totals.input += usage.input ?? 0;
    totals.output += usage.output ?? 0;
    totals.cacheRead += usage.cacheRead ?? 0;
    totals.cacheWrite += usage.cacheWrite ?? 0;
    totals.cost += usage.cost?.total ?? 0;
}

function formatTokens(count: number): string {
    if (count < 1000) return count.toString();
    if (count < 10000) return `${(count / 1000).toFixed(1)}k`;
    if (count < 1000000) return `${Math.round(count / 1000)}k`;
    if (count < 10000000) return `${(count / 1000000).toFixed(1)}M`;
    return `${Math.round(count / 1000000)}M`;
}

function formatCwd(cwd: string, home: string | undefined): string {
    if (!home) return cwd;
    const resolvedCwd = resolve(cwd);
    const resolvedHome = resolve(home);
    const rel = relative(resolvedHome, resolvedCwd);
    const insideHome = rel === "" || (rel !== ".." && !rel.startsWith(`..${sep}`) && !isAbsolute(rel));
    if (!insideHome) return cwd;
    return rel === "" ? "~" : `~${sep}${rel}`;
}

function sanitizeStatusText(text: string): string {
    return text.replace(/[\r\n\t]/g, " ").replace(/ +/g, " ").trim();
}

function renderFooter(
    ctx: ExtensionContext,
    pi: ExtensionAPI,
    footerData: ReadonlyFooterDataProvider,
    theme: Theme,
    width: number,
): string[] {
    const model = ctx.model;

    // Cumulative usage across all entries (same rules as the built-in footer).
    const totals: Totals = { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, cost: 0 };
    let latestCacheHitRate: number | undefined;
    for (const entry of ctx.sessionManager.getEntries()) {
        if (entry.type === "usage") {
            addUsage(totals, (entry as { usage?: UsageLike }).usage);
        } else if (entry.type === "message") {
            const msg = (entry as { message?: { role?: string; usage?: UsageLike } }).message;
            if (msg?.role === "assistant") {
                addUsage(totals, msg.usage);
                if (msg.usage) {
                    const promptTokens =
                        (msg.usage.input ?? 0) + (msg.usage.cacheRead ?? 0) + (msg.usage.cacheWrite ?? 0);
                    latestCacheHitRate =
                        promptTokens > 0 ? ((msg.usage.cacheRead ?? 0) / promptTokens) * 100 : undefined;
                }
            } else if (msg?.role === "toolResult" && msg.usage) {
                addUsage(totals, msg.usage);
            }
        } else if (entry.type === "branch_summary" || entry.type === "compaction") {
            addUsage(totals, (entry as { usage?: UsageLike }).usage);
        }
    }

    // Context usage; percent is null right after compaction, undefined before any usage.
    const contextUsage = ctx.getContextUsage();
    const percentValue = contextUsage?.percent ?? 0;
    const percent = contextUsage?.percent !== null ? percentValue.toFixed(1) : "?";

    // Line 1: cwd, optional branch and session name.
    let pwd = formatCwd(ctx.sessionManager.getCwd(), process.env.HOME || process.env.USERPROFILE);
    const branch = footerData.getGitBranch();
    if (branch) pwd = `${pwd} (${branch})`;
    const sessionName = ctx.sessionManager.getSessionName();
    if (sessionName) pwd = `${pwd} • ${theme.italic(sessionName)}`;

    // Line 2 left: cost, tokens, then cache/context group.
    const parts: string[] = [];
    // ponytail: only the kimi-coding case is detectable; modelRuntime.isUsingSubscription is not exposed.
    const usingSubscription = model ? model.provider === "kimi-coding" : false;
    if (totals.cost || usingSubscription) {
        parts.push(`$${totals.cost.toFixed(3)}${usingSubscription ? " (sub)" : ""}`);
    }
    parts.push("•");
    if (totals.input) parts.push(`↑${formatTokens(totals.input)}`);
    if (totals.output) parts.push(`↓${formatTokens(totals.output)}`);
    if (totals.cacheWrite) parts.push(`W${formatTokens(totals.cacheWrite)}`);
    const group: string[] = [];
    if ((totals.cacheRead > 0 || totals.cacheWrite > 0) && latestCacheHitRate !== undefined) {
        group.push(`CHR: ${latestCacheHitRate.toFixed(1)}%`);
    }
    const ctxValue = percent === "?" ? "?" : `${percent}%`;
    let ctxColored = ctxValue;
    if (percent !== "?" && percentValue > 90) ctxColored = theme.fg("error", ctxValue);
    else if (percent !== "?" && percentValue > 70) ctxColored = theme.fg("warning", ctxValue);
    group.push(`CTX: ${ctxColored}`);
    parts.push(`(${group.join(" ")})`);
    if (process.env.PI_EXPERIMENTAL === "1") {
        parts.push(`${theme.fg("dim", "•")} ${theme.bold(theme.fg("warning", "xp"))}`);
    }

    let statsLeft = parts.join(" ");
    let statsLeftWidth = visibleWidth(statsLeft);
    if (statsLeftWidth > width) {
        statsLeft = truncateToWidth(statsLeft, width, "...");
        statsLeftWidth = visibleWidth(statsLeft);
    }

    // Line 2 right: model, optional provider and thinking level.
    const modelName = model?.id || "no-model";
    let rightSide = modelName;
    if (model?.reasoning) {
        const level = pi.getThinkingLevel() || "off";
        rightSide = level === "off" ? `${modelName} • thinking off` : `${modelName} • ${level}`;
    }
    if (footerData.getAvailableProviderCount() > 1 && model) {
        const withProvider = `(${model.provider}) ${rightSide}`;
        if (statsLeftWidth + 2 + visibleWidth(withProvider) <= width) {
            rightSide = withProvider;
        }
    }

    const rightWidth = visibleWidth(rightSide);
    const minPadding = 2;
    let statsLine: string;
    if (statsLeftWidth + minPadding + rightWidth <= width) {
        statsLine = statsLeft + " ".repeat(width - statsLeftWidth - rightWidth) + rightSide;
    } else {
        const availableForRight = width - statsLeftWidth - minPadding;
        if (availableForRight > 0) {
            const truncatedRight = truncateToWidth(rightSide, availableForRight, "");
            statsLine =
                statsLeft +
                " ".repeat(Math.max(0, width - statsLeftWidth - visibleWidth(truncatedRight))) +
                truncatedRight;
        } else {
            statsLine = statsLeft;
        }
    }

    // Dim the two halves separately so any colored part inside statsLeft survives the outer dim.
    const dimStatsLeft = theme.fg("dim", statsLeft);
    const dimRemainder = theme.fg("dim", statsLine.slice(statsLeft.length));
    const lines = [
        truncateToWidth(theme.fg("dim", pwd), width, theme.fg("dim", "...")),
        dimStatsLeft + dimRemainder,
    ];

    // Line 3: extension statuses, sorted by key.
    const statuses = footerData.getExtensionStatuses();
    if (statuses.size > 0) {
        const statusLine = Array.from(statuses.entries())
            .sort(([a], [b]) => a.localeCompare(b))
            .map(([, text]) => sanitizeStatusText(text))
            .join(" ");
        lines.push(truncateToWidth(statusLine, width, theme.fg("dim", "...")));
    }

    return lines;
}

export default function footer(pi: ExtensionAPI): void {
    pi.on("session_start", async (_event, ctx) => {
        if (ctx.mode !== "tui") return;
        ctx.ui.setFooter((tui, theme, footerData) => {
            const unsubscribe = footerData.onBranchChange(() => tui.requestRender());
            return {
                dispose: unsubscribe,
                invalidate() {},
                render(width: number): string[] {
                    return renderFooter(ctx, pi, footerData, theme, width);
                },
            };
        });
    });

    pi.on("session_shutdown", async (_event, ctx) => {
        if (ctx.mode !== "tui") return;
        ctx.ui.setFooter(undefined);
    });
}
