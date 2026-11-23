/*
 * Publishes the agent state as the tmux window option @pi_state
 * (run | ask | idle). "ask" = blocked on ask_user_question. The status bar
 * (.tmux.conf) reads it. Outside tmux this is a no-op.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { execFile } from "node:child_process";

const ASK_TOOL = "ask_user_question";

// shortcut: targets the pane's window, so two pi panes in one window share a state; split windows are rare here.
function setState(state: "run" | "ask" | "idle" | null) {
    const pane = process.env.TMUX_PANE;
    if (!process.env.TMUX || !pane) {
        return;
    }
    const args = state
        ? ["set-option", "-w", "-t", pane, "@pi_state", state]
        : ["set-option", "-wu", "-t", pane, "@pi_state"];
    execFile("tmux", args, () => {});
}

export default function (pi: ExtensionAPI) {
    pi.on("agent_start", () => setState("run"));
    pi.on("tool_execution_start", (event) => {
        if (event.toolName === ASK_TOOL) {
            setState("ask");
        }
    });
    pi.on("tool_execution_end", (event) => {
        if (event.toolName === ASK_TOOL) {
            setState("run");
        }
    });
    pi.on("agent_settled", () => setState("idle"));
    pi.on("session_shutdown", () => setState(null));
}
