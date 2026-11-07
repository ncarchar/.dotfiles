/*
 * /claude-usage [provider] - show Claude subscription usage (5h / 7d windows).
 * Uses pi's stored Anthropic OAuth token against Anthropic's undocumented
 * /api/oauth/usage endpoint (what Claude Code's /usage calls).
 * shortcut: undocumented endpoint, response shape is rendered generically; fix if Anthropic changes it.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

interface Window {
    utilization?: number | null;
    resets_at?: string | null;
}

function formatReset(iso: string): string {
    const mins = Math.max(0, Math.round((new Date(iso).getTime() - Date.now()) / 60000));
    const h = Math.floor(mins / 60);
    return h >= 24 ? `${Math.floor(h / 24)}d ${h % 24}h` : `${h}h ${mins % 60}m`;
}

export default function (pi: ExtensionAPI) {
    pi.registerCommand("claude-usage", {
        description: "Show Claude subscription usage (5h and 7d windows)",
        handler: async (args, ctx) => {
            const provider = args.trim() || "anthropic";
            const token = await ctx.modelRegistry.getApiKeyForProvider(provider);
            if (!token) {
                ctx.ui.notify(`No credentials for provider "${provider}"`, "error");
                return;
            }
            try {
                const res = await fetch("https://api.anthropic.com/api/oauth/usage", {
                    headers: {
                        Authorization: `Bearer ${token}`,
                        "anthropic-beta": "oauth-2025-04-20",
                    },
                });
                if (!res.ok) {
                    ctx.ui.notify(`Usage request failed: HTTP ${res.status} ${await res.text()}`, "error");
                    return;
                }
                const data = (await res.json()) as Record<string, Window | null>;
                const lines = Object.entries(data)
                    .filter(([, v]) => v && typeof v.utilization === "number")
                    .map(([k, v]) => {
                        const reset = v!.resets_at ? `, resets in ${formatReset(v!.resets_at)}` : "";
                        return `${k}: ${v!.utilization}%${reset}`;
                    });
                ctx.ui.notify(lines.length ? lines.join("\n") : JSON.stringify(data), "info");
            } catch (e) {
                ctx.ui.notify(`Usage request failed: ${e instanceof Error ? e.message : String(e)}`, "error");
            }
        },
    });
}
