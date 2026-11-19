/*
 * Rings a chime and flags the tmux window (bell flag -> "!" in a yellow
 * window-status style) when Pi finishes a full turn (agent_settled). The
 * flag clears once the window is focused again.
 *
 * Sound uses paplay (PulseAudio/PipeWire) so it rings regardless of terminal
 * bell settings, and works from any tmux window.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { execFile } from "node:child_process";
import { homedir } from "node:os";

const SOUND = `${homedir()}/.local/share/sounds/pi-turn.mp3`;

function ring() {
    process.stdout.write("\x07");
    execFile("paplay", [SOUND], () => {});
}

export default function (pi: ExtensionAPI) {
    pi.on("agent_settled", ring);
    // A pending question blocks the turn, so agent_settled never fires for it.
    pi.on("tool_execution_start", (event) => {
        if (event.toolName === "ask_user_question") {
            ring();
        }
    });
}