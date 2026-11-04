/* Assert-based check for pruneSessions. Run: node lib/session-retention.test.ts */
import { mkdtempSync, mkdirSync, writeFileSync, utimesSync, existsSync, rmSync, chmodSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { pruneSessions } from "../session-retention.ts";

const root = mkdtempSync(join(tmpdir(), "pi-sessions-"));
const touch = (dir: string, name: string, daysOld: number) => {
    const path = join(dir, name);
    writeFileSync(path, "{}");
    const t = new Date(Date.now() - daysOld * 24 * 60 * 60 * 1000);
    utimesSync(path, t, t);
    return path;
};

// group dir that still has live sessions: old pair pruned, rest survives
const live = join(root, "--home-x-proj--");
mkdirSync(live);
touch(live, "old.jsonl", 40);
touch(live, "old.jsonl.acp.json", 40);
const kept = touch(live, "kept.jsonl", 40); // old but protected by keep set
touch(live, "kept.jsonl.acp.json", 40);
touch(live, "new.jsonl", 1);
touch(live, "new.jsonl.acp.json", 1);

// group dir whose every session is old: dir itself should disappear
const gone = join(root, "--home-x-gone--");
mkdirSync(gone);
touch(gone, "old2.jsonl", 40);
touch(gone, "old2.jsonl.acp.json", 40);

const { removedFiles, removedDirs } = pruneSessions(root, Date.now() - 30 * 24 * 60 * 60 * 1000, new Set([kept, kept + ".acp.json"]));

const assert = (cond: boolean, msg: string) => {
    if (!cond) {
        throw new Error("FAIL: " + msg);
    }
};

assert(removedFiles === 2, `expected 2 file pairs removed, got ${removedFiles}`);
assert(removedDirs === 1, `expected empty dir removed, got ${removedDirs}`);
assert(!existsSync(join(live, "old.jsonl")), "old.jsonl pruned");
assert(!existsSync(join(live, "old.jsonl.acp.json")), "sidecar pruned");
assert(existsSync(kept), "kept file survives");
assert(existsSync(join(live, "kept.jsonl.acp.json")), "kept sidecar survives");
assert(existsSync(join(live, "new.jsonl")), "fresh session survives");
assert(existsSync(live), "group dir with live sessions survives");
assert(!existsSync(gone), "fully-emptied group dir removed");
assert(existsSync(root), "root untouched");

// missing dir must not throw
const missing = pruneSessions(join(root, "nope"), Date.now(), new Set());
assert(missing.removedFiles === 0, "missing dir is a no-op");

// an unreadable subdir (sandbox mount, race) must not abort the walk
const root2 = mkdtempSync(join(tmpdir(), "pi-sessions-"));
const a2 = join(root2, "--a--");
mkdirSync(a2);
touch(a2, "o.jsonl", 40);
const b2 = join(root2, "--b--");
mkdirSync(b2);
touch(b2, "o.jsonl", 40);
const bad2 = join(root2, "--bad--");
mkdirSync(bad2);
touch(bad2, "o.jsonl", 40);
chmodSync(bad2, 0o000);
const r2 = pruneSessions(root2, Date.now() - 30 * 24 * 60 * 60 * 1000, new Set());
chmodSync(bad2, 0o755);
assert(r2.removedFiles === 2, "pruned good dirs despite unreadable dir");
assert(r2.removedDirs === 2, "removed good dirs despite unreadable dir");
assert(existsSync(bad2), "unreadable dir left alone, no abort");
rmSync(root2, { recursive: true, force: true });

rmSync(root, { recursive: true, force: true });
console.log("PASS: old pruned, fresh+kept survive, empty dir removed, missing dir safe");
// Regression: getSessionDir() is the per-cwd folder, not the root. The handler must prune siblings.
const { default: register } = await import("../session-retention.ts");
const root3 = mkdtempSync(join(tmpdir(), "pi-sessions-"));
const cur = join(root3, "--home-x-cur--");
const sibOld = join(root3, "--home-x-sibold--");
const sibEmpty = join(root3, "--tmp--");
for (const d of [cur, sibOld, sibEmpty]) {
    mkdirSync(d);
}
touch(cur, "old.jsonl", 40);
touch(sibOld, "old.jsonl", 40);
let handler: any;
register({ on: (_e: string, h: any) => { handler = h; } } as any);
handler({}, { sessionManager: { getSessionDir: () => cur, getSessionFile: () => join(cur, "now.jsonl") }, ui: { notify() {} } });
assert(!existsSync(join(cur, "old.jsonl")), "current folder pruned");
assert(!existsSync(join(sibOld, "old.jsonl")), "sibling folder pruned");
assert(!existsSync(sibOld), "emptied sibling folder removed");
assert(!existsSync(sibEmpty), "already-empty sibling folder removed");
assert(existsSync(cur), "current cwd folder kept even though empty");
rmSync(root3, { recursive: true, force: true });
console.log("PASS: handler prunes sibling cwd folders, keeps current folder");
