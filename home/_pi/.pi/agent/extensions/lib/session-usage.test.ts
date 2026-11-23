/* Assert-based check for accumulateUsage.
 * Run: node --experimental-strip-types lib/session-usage.test.ts */
import { accumulateUsage, type EntryLike } from "./session-usage.ts";

const assert = (cond: boolean, msg: string) => {
    if (!cond) {
        throw new Error("FAIL: " + msg);
    }
};

const assistant = (input: number, output: number, cost: number, cacheRead = 0): EntryLike => ({
    type: "message",
    message: { role: "assistant", usage: { input, output, cacheRead, cacheWrite: 0, cost: { total: cost } } },
});
const toolResult: EntryLike = { type: "message", message: { role: "toolResult", usage: { input: 2, output: 0 } } };

const entries: EntryLike[] = [assistant(10, 5, 0.1), toolResult, assistant(20, 8, 0.2, 10)];

const first = accumulateUsage(entries, undefined);
assert(first.totals.input === 32, `input: ${first.totals.input}`);
assert(first.totals.output === 13, `output: ${first.totals.output}`);
assert(Math.abs(first.totals.cost - 0.3) < 1e-9, `cost: ${first.totals.cost}`);
assert(Math.abs((first.latestCacheHitRate ?? 0) - (10 / 30) * 100) < 1e-9, `cache hit rate: ${first.latestCacheHitRate}`);

// Same history again: identical numbers, no double count.
const again = accumulateUsage(entries, first.cache);
assert(again.totals.input === 32 && again.totals.output === 13, "idempotent rerun");
assert(Math.abs(again.totals.cost - 0.3) < 1e-9, `idempotent cost: ${again.totals.cost}`);

// One entry appended: only that one adds.
const grown = [...entries, assistant(7, 3, 0.05)];
const grownTotals = accumulateUsage(grown, again.cache).totals;
assert(grownTotals.input === 39 && grownTotals.output === 16, "append adds once");
assert(Math.abs(grownTotals.cost - 0.35) < 1e-9, `append cost: ${grownTotals.cost}`);

// The newest entry gains usage while streaming: the tail is folded fresh, not twice.
const streaming = [...entries, { type: "message", message: { role: "assistant", usage: {} } }];
const before = accumulateUsage(streaming, first.cache);
const filled = [...entries, assistant(4, 2, 0.02)];
const after = accumulateUsage(filled, before.cache);
assert(after.totals.input === 36 && after.totals.output === 15, `tail fill: ${after.totals.input}/${after.totals.output}`);
assert(Math.abs(after.totals.cost - 0.32) < 1e-9, `tail fill cost: ${after.totals.cost}`);

// History replaced (branch switch / compaction): recompute instead of reusing stale totals.
const swapped = [assistant(100, 1, 1)];
const swappedResult = accumulateUsage(swapped, after.cache);
assert(
    swappedResult.totals.input === 100 && swappedResult.totals.output === 1,
    `branch switch: ${swappedResult.totals.input}`
);

// Empty session.
const empty = accumulateUsage([], swappedResult.cache);
assert(empty.totals.input === 0 && empty.latestCacheHitRate === undefined, "empty session");

console.log("PASS: incremental totals match a full rescan across append, rerun, streaming tail, branch switch, empty");
