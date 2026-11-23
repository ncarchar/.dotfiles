/*
 * Destructive bash patterns worth an explicit confirmation even inside
 * pi-sandbox, which allows writes in the repo and network access to github.com.
 *
 * Plain module (no default export) so pi does not auto-load it as an extension.
 */

export const UNSAFE_PATTERNS = [
    "sudo",
    "chmod 777",
    "docker system prune",
    "git reset --hard",
    "git push --force",
    "git push -f",
    "shutdown",
    "reboot",
    "tmux kill-server",
];

/** The matching pattern, or undefined when the command is safe to run.
 *  shortcut: substring match, so `git commit -m "fix shutdown"` also prompts;
 *  upgrade to a word-boundary regex if that annoys. */
export function isUnsafe(command: string): string | undefined {
    return UNSAFE_PATTERNS.find((pattern) => command.includes(pattern));
}
