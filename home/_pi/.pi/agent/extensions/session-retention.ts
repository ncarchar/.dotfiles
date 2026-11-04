/*
 * Auto-expire pi sessions: on every session start, delete session files whose
 * .jsonl has not been touched in RETENTION_DAYS days. Runs inside the pi
 * process, so it also prunes when pi is started with --continue/--resume.
 *
 * shortcut: deletes purely by age; the current session is skipped explicitly,
 * but a *second* concurrently running pi instance that has an old session open
 * in another pane would lose that file. Upgrade to a lock/lockfile check if
 * you regularly run multiple pi instances on month-old sessions.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { readdirSync, statSync, rmSync, rmdirSync } from "node:fs";
import { basename, dirname, join } from "node:path";

const RETENTION_DAYS = 14;

const SIDECAR_SUFFIX = ".acp.json";

export interface PruneResult {
    removedFiles: number;
    removedDirs: number;
}

/** Delete every *.jsonl under `root` older than `cutoffMs` (and its sidecar),
 *  except files listed in `keep`. Removes group dirs left empty. */
export function pruneSessions(root: string, cutoffMs: number, keep: Set<string>): PruneResult {
    const result: PruneResult = { removedFiles: 0, removedDirs: 0 };
    const dirs: string[] = [];

    const walk = (dir: string) => {
        let entries;
        try {
            entries = readdirSync(dir, { withFileTypes: true });
        } catch {
            return; // unreadable dir (sandbox mount, race): skip it, keep pruning
        }
        for (const entry of entries) {
            const path = join(dir, entry.name);
            if (entry.isDirectory()) {
                walk(path);
                dirs.push(path);
                continue;
            }
            if (!entry.isFile() || !entry.name.endsWith(".jsonl") || entry.name.endsWith(SIDECAR_SUFFIX)) {
                continue;
            }
            try {
                if (keep.has(path) || statSync(path).mtimeMs >= cutoffMs) {
                    continue;
                }
            } catch {
                continue; // stat failed (race): don't delete what we can't age
            }
            try {
                rmSync(path);
                rmSync(path + SIDECAR_SUFFIX, { force: true });
                result.removedFiles++;
            } catch {
                // rm failed on one file: move on, don't abort the whole walk
            }
        }
    };

    walk(root); // never throws: every fs call above is guarded
    for (const dir of dirs) {
        if (keep.has(dir)) {
            continue; // e.g. the current cwd's folder: pi writes its session file there later
        }
        try {
            rmdirSync(dir); // only ever succeeds on empty dirs
            result.removedDirs++;
        } catch {
            // not empty: leave it
        }
    }
    return result; // read-only rm could fail on every file; dirs then stay non-empty and are kept
}

export default function (pi: ExtensionAPI) {
    pi.on("session_start", (event, ctx) => {
        const sessionDir = ctx.sessionManager.getSessionDir();
        if (!sessionDir) {
            return;
        }
        // getSessionDir() is the per-cwd folder (--home-x-y--) under the default root;
        // walk the parent so every cwd's sessions are pruned. A custom sessionDir is the root itself.
        // shortcut: a custom sessionDir literally named --x-- would be treated as a cwd folder, fix if that ever happens.
        const root = /^--.*--$/.test(basename(sessionDir)) ? dirname(sessionDir) : sessionDir;
        const cutoffMs = Date.now() - RETENTION_DAYS * 24 * 60 * 60 * 1000;

        // Never delete the session pi is currently running on (or just left).
        const keep = new Set<string>([sessionDir]);
        for (const file of [ctx.sessionManager.getSessionFile(), event.previousSessionFile]) {
            if (file) {
                keep.add(file);
                keep.add(file + SIDECAR_SUFFIX);
            }
        }

        const { removedFiles } = pruneSessions(root, cutoffMs, keep);
        if (removedFiles > 0) {
            ctx.ui.notify(`Pruned ${removedFiles} session${removedFiles === 1 ? "" : "s"} older than ${RETENTION_DAYS} days`, "info");
        }
    });
}
