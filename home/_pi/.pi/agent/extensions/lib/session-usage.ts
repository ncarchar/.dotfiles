/*
 * Cumulative token/cost totals for the footer, rescanning only what changed.
 *
 * The footer re-renders on every streamed token, so walking the whole session
 * per frame is O(entries) per frame. Everything but the newest entry is frozen
 * once folded; the newest entry may still gain usage while it streams, so it is
 * folded fresh into a copy each time.
 *
 * Plain module (no default export) so pi does not auto-load it as an extension.
 */

export interface UsageLike {
    input?: number;
    output?: number;
    cacheRead?: number;
    cacheWrite?: number;
    cost?: { total?: number };
}

export interface Totals {
    input: number;
    output: number;
    cacheRead: number;
    cacheWrite: number;
    cost: number;
}

export interface EntryLike {
    type: string;
    usage?: UsageLike;
    message?: { role?: string; usage?: UsageLike };
}

export interface UsageCache {
    /** entries[0..folded) are already in `totals`. */
    folded: number;
    /** The last folded entry, by reference; a mismatch means the history changed. */
    last: unknown;
    totals: Totals;
    latestCacheHitRate: number | undefined;
}

export function addUsage(totals: Totals, usage: UsageLike | null | undefined): void {
    if (!usage) return;
    totals.input += usage.input ?? 0;
    totals.output += usage.output ?? 0;
    totals.cacheRead += usage.cacheRead ?? 0;
    totals.cacheWrite += usage.cacheWrite ?? 0;
    totals.cost += usage.cost?.total ?? 0;
}

function foldEntry(entry: EntryLike, totals: Totals, rate: number | undefined): number | undefined {
    if (entry.type === "usage") {
        addUsage(totals, entry.usage);
    } else if (entry.type === "message") {
        const msg = entry.message;
        if (msg?.role === "assistant") {
            addUsage(totals, msg.usage);
            if (msg.usage) {
                const promptTokens =
                    (msg.usage.input ?? 0) + (msg.usage.cacheRead ?? 0) + (msg.usage.cacheWrite ?? 0);
                rate = promptTokens > 0 ? ((msg.usage.cacheRead ?? 0) / promptTokens) * 100 : undefined;
            }
        } else if (msg?.role === "toolResult" && msg.usage) {
            addUsage(totals, msg.usage);
        }
    } else if (entry.type === "branch_summary" || entry.type === "compaction") {
        addUsage(totals, entry.usage);
    }
    return rate;
}

export function accumulateUsage(
    entries: readonly EntryLike[],
    cache: UsageCache | undefined
): { totals: Totals; latestCacheHitRate: number | undefined; cache: UsageCache } {
    const prefixEnd = Math.max(0, entries.length - 1);
    const stale = cache === undefined || prefixEnd < cache.folded || entries[cache.folded - 1] !== cache.last;
    let state: UsageCache = stale
        ? {
              folded: 0,
              last: undefined,
              totals: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, cost: 0 },
              latestCacheHitRate: undefined,
          }
        : cache;

    if (state.folded < prefixEnd) {
        // Copy before extending so the caller's previous snapshot stays valid.
        state = { ...state, totals: { ...state.totals } };
        for (let i = state.folded; i < prefixEnd; i++) {
            const entry = entries[i]!;
            state.latestCacheHitRate = foldEntry(entry, state.totals, state.latestCacheHitRate);
            state.last = entry;
            state.folded = i + 1;
        }
    }

    const totals = { ...state.totals };
    let latestCacheHitRate = state.latestCacheHitRate;
    const tail = entries[prefixEnd];
    if (tail !== undefined) {
        latestCacheHitRate = foldEntry(tail, totals, latestCacheHitRate);
    }
    return { totals, latestCacheHitRate, cache: state };
}
