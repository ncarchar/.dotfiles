/*
 * /price [model] - show OpenRouter prices ($/Mtok) for the current model
 * (or the given id) as a table. Prices come from the shared cache file
 * ~/.cache/pi/openrouter-pricing.json, fetched from openrouter.ai on demand.
 */

import { mkdirSync, readdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const settingsFile = join(
    process.env.XDG_CONFIG_HOME || join(process.env.HOME || "", ".config"),
    "pi",
    "agent",
    "settings.json",
);

interface PricingEntry {
    prompt: number;
    completion: number;
    cacheRead: number;
}

const cacheFile = join(
    process.env.XDG_CACHE_HOME || join(process.env.HOME || "", ".cache"),
    "pi",
    "openrouter-pricing.json",
);

function loadCache(): Map<string, PricingEntry> | undefined {
    try {
        return new Map(Object.entries(JSON.parse(readFileSync(cacheFile, "utf8"))));
    } catch {
        return undefined;
    }
}

// Settings lives in ~/.pi; XDG_CONFIG_HOME may point elsewhere (e.g. sandbox),
// so prefer the real ~/.pi path when it exists.
function readSettingsModels(): string[] {
    for (const p of [join(process.env.HOME || "", ".pi/agent/settings.json"), settingsFile]) {
        try {
            const json = JSON.parse(readFileSync(p, "utf8")) as { enabledModels?: string[] };
            if (json.enabledModels) return json.enabledModels;
        } catch {}
    }
    return [];
}

// Resolve a settings id (possibly a bare alias like "deepseek-flash") to an
// OpenRouter id in the pricing map.
function lookup(map: Map<string, PricingEntry>, id: string): PricingEntry | undefined {
    const direct = map.get(id) ?? map.get(id.replace(/^[^/]+\//, ""));
    if (direct) return direct;
    if (!id.includes("/")) {
        const matches = [...map.keys()].filter((k) => k.endsWith(`/${id}`) || k.split("/").pop() === id);
        if (matches.length === 1) return map.get(matches[0]);
    }
    return undefined;
}

function formatTable(
    modelIds: string[],
    resolve: (id: string) => PricingEntry | undefined,
    missing: (id: string) => void,
    mix: {
        inputRatio: number;
        cacheReadRatio: number;
        outputRatio: number;
        promptInputRatio: number;
        promptCacheRatio: number;
    },
): string[] {
    const perM = (n: number) => `$${(n * 1e6).toFixed(2)}`;
    const rows: Array<[string, string, string, string, string, string]> = [];
    for (const id of modelIds) {
        const e = resolve(id);
        if (!e) {
            missing(id);
            continue;
        }
        // Weighted prompt price per Mtok given the session input/cached mix.
        const weighted = mix.promptInputRatio * e.prompt + mix.promptCacheRatio * e.cacheRead;
        // Blended price per Mtok over all tokens (input + cached + output) at
        // the observed token mix: the rough "what you actually pay" index.
        const index =
            mix.inputRatio * e.prompt +
            mix.cacheReadRatio * e.cacheRead +
            mix.outputRatio * e.completion;
        rows.push([id, perM(e.prompt), perM(e.cacheRead), perM(e.completion), perM(weighted), perM(index)]);
    }
    if (rows.length === 0) return [];
    const headers = ["model", "input", "cached", "output", "weighted", "index"];
    // Column width fits header, all cells, and one space of padding each side.
    const w = [0, 1, 2, 3, 4, 5].map((i) =>
        Math.max(headers[i].length, ...rows.map((r) => r[i].length)),
    );
    const pad = (i: number, s: string) =>
        i === 0 ? ` ${s.padEnd(w[i])} ` : ` ${s.padStart(w[i])} `;
    const line = (l: string, m: string, r: string) => l + w.map((x) => "─".repeat(x + 2)).join(m) + r;
    const cell = (vals: string[]) => "│" + vals.map((v, i) => pad(i, v)).join("│") + "│";
    return [
        line("┌", "┬", "┐"),
        cell(headers),
        line("├", "┼", "┤"),
        ...rows.map((r) => cell(r)),
        line("└", "┴", "┘"),
    ];
}

async function fetchPricing(): Promise<Map<string, PricingEntry> | undefined> {
    try {
        const res = await fetch("https://openrouter.ai/api/v1/models");
        const json = (await res.json()) as {
            data?: Array<{ id: string; pricing?: Record<string, string> }>;
        };
        const map = new Map(
            (json.data ?? []).map((m) => [
                m.id,
                {
                    prompt: Number(m.pricing?.prompt ?? 0),
                    completion: Number(m.pricing?.completion ?? 0),
                    cacheRead: Number(m.pricing?.input_cache_read ?? 0),
                },
            ]),
        );
        mkdirSync(join(cacheFile, ".."), { recursive: true });
        writeFileSync(cacheFile, JSON.stringify(Object.fromEntries(map)));
        return map;
    } catch {
        return undefined;
    }
}

// Aggregate token ratio across all session logs; computed once per pi run.
let sessionTotals: { summary: string; mix: {
        inputRatio: number;
        cacheReadRatio: number;
        outputRatio: number;
        promptInputRatio: number;
        promptCacheRatio: number;
    } } | undefined;

function computeSessionTotals(): { summary: string; mix: {
        inputRatio: number;
        cacheReadRatio: number;
        outputRatio: number;
        promptInputRatio: number;
        promptCacheRatio: number;
    } } {
    if (sessionTotals !== undefined) return sessionTotals;
    let input = 0,
        output = 0,
        cacheRead = 0,
        cost = 0;
    let costIn = 0,
        costOut = 0,
        costCacheR = 0;
    try {
        const sessionsDir = join(process.env.HOME || "", ".pi/agent/sessions");
        for (const dir of readdirSync(sessionsDir)) {
            const d = join(sessionsDir, dir);
            if (!statSync(d).isDirectory()) continue;
            for (const f of readdirSync(d)) {
                if (!f.endsWith(".jsonl")) continue;
                for (const line of readFileSync(join(d, f), "utf8").split("\n")) {
                    if (!line.includes('"usage"')) continue;
                    let e: any;
                    try {
                        e = JSON.parse(line);
                    } catch {
                        continue;
                    }
                    const u = e.usage ?? e.message?.usage;
                    if (!u || typeof u.input !== "number") continue;
                    if (e.type === "usage" || e.message?.role === "assistant") {
                        input += u.input || 0;
                        output += u.output || 0;
                        cacheRead += u.cacheRead || 0;
                        cost += u.cost?.total || 0;
                        costIn += u.cost?.input || 0;
                        costOut += u.cost?.output || 0;
                        costCacheR += u.cost?.cacheRead || 0;
                    }
                }
            }
        }
    } catch {}
    const prompt = input + cacheRead;
    const allTok = prompt + output;
    const mix = {
        inputRatio: allTok > 0 ? input / allTok : 0,
        cacheReadRatio: allTok > 0 ? cacheRead / allTok : 0,
        outputRatio: allTok > 0 ? output / allTok : 0,
        promptInputRatio: prompt > 0 ? input / prompt : 0,
        promptCacheRatio: prompt > 0 ? cacheRead / prompt : 0,
    };
    const pct = (n: number) => (prompt > 0 ? `${((n / prompt) * 100).toFixed(1)}%` : "-");
    const spendTotal = costIn + costOut + costCacheR;
    const spendPct = (n: number) =>
        spendTotal > 0 ? `${((n / spendTotal) * 100).toFixed(0)}%` : "-";
    sessionTotals = {
        mix,
        summary: [
            `all sessions: input ${pct(input)} • cached ${pct(cacheRead)} • output ${(output / 1e6).toFixed(1)}Mtok • $${cost.toFixed(2)}`,
            `spend: input ${spendPct(costIn)} • cached ${spendPct(costCacheR)} • output ${spendPct(costOut)}`,
        ].join("\n"),
    };
    return sessionTotals;
}

export default function price(pi: ExtensionAPI): void {
    pi.registerCommand("price", {
        description: "Show OpenRouter prices ($/Mtok); all enabled models, or one if given",
        handler: async (arg, ctx) => {
            const wanted = arg && arg.trim() ? arg.trim() : undefined;
            const ids = wanted
                ? [wanted]
                : readSettingsModels().length > 0
                  ? readSettingsModels()
                  : ctx.model?.id
                    ? [ctx.model.id]
                    : [];
            if (ids.length === 0) {
                ctx.ui.notify("No model specified and none in settings.", "warning");
                return;
            }
            let map = loadCache();
            const totals = computeSessionTotals();
            const resolve = (id: string) => (map ? lookup(map, id) : undefined);
            let lines: string[] = [];
            const missing: string[] = [];
            const collect = () =>
                (lines = formatTable(ids, resolve, (id) => missing.push(id), totals.mix));
            collect();
            if (missing.length > 0) {
                map = (await fetchPricing()) ?? map;
                missing.length = 0;
                collect();
            }
            if (lines.length === 0) {
                ctx.ui.notify(`No OpenRouter pricing found for: ${missing.join(", ")}`, "warning");
                return;
            }
            ctx.ui.notify(`${totals.summary}\n\n${lines.join("\n")}`, "info");
            if (missing.length > 0) {
                ctx.ui.notify(`No pricing found for: ${missing.join(", ")}`, "warning");
            }
        },
    });
}
