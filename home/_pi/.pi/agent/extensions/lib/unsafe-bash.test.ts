/* Assert-based check for isUnsafe.
 * Run: node --experimental-strip-types lib/unsafe-bash.test.ts */
import { UNSAFE_PATTERNS, isUnsafe } from "./unsafe-bash.ts";

const assert = (cond: boolean, msg: string) => {
    if (!cond) {
        throw new Error("FAIL: " + msg);
    }
};

assert(UNSAFE_PATTERNS.length === 9, `expected 9 patterns, got ${UNSAFE_PATTERNS.length}`);

for (const pattern of UNSAFE_PATTERNS) {
    assert(isUnsafe(`prefix ${pattern} suffix`) === pattern, `expected \`${pattern}\` to be flagged`);
    assert(isUnsafe(pattern) === pattern, `expected bare \`${pattern}\` to be flagged`);
}

for (const safe of ["ls -la", "echo x > f", "git status", "npm install left-pad", "rg release"]) {
    assert(isUnsafe(safe) === undefined, `expected \`${safe}\` not to be flagged`);
}

console.log("PASS: 9 patterns flagged; ls -la, echo x > f, git status, npm install, rg release not flagged");
