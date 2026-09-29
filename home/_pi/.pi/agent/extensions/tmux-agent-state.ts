// @ts-nocheck
import { execFile } from "node:child_process";

const pane = process.env.TMUX_PANE;

function enabled() {
    return !!process.env.TMUX && !!pane;
}

function tmux(args: string[]): void {
    execFile("tmux", args, () => {});
}

function setState(state: string): void {
    tmux(["set", "-p", "-t", pane!, "@pi_agent_state", state]);
}

function toast(text: string): void {
    tmux(["display-message", "-d", "5000", text]);
}

export default function (pi) {
    if (!enabled()) {
        return;
    }

    let agentActive = false;
    let blockedCount = 0;
    let blockedTitle: string | undefined;
    let lastState: string | undefined;

    function publish() {
        const state = blockedCount > 0 ? "blocked" : agentActive ? "working" : "idle";
        if (state === lastState) {
            return;
        }
        lastState = state;
        setState(state);
    }

    pi.on("session_start", (_event, ctx) => {
        if (ctx?.mode !== "tui") {
            return;
        }
        publish();
    });

    pi.on("ui_prompt_start", (event) => {
        const first = blockedCount === 0;
        blockedCount += 1;
        blockedTitle = event?.title ?? blockedTitle;
        if (first) {
            toast(`pi: waiting for input${blockedTitle ? ` (${blockedTitle})` : ""}`);
        }
        publish();
    });

    pi.on("ui_prompt_end", () => {
        blockedCount = Math.max(0, blockedCount - 1);
        if (blockedCount === 0) {
            blockedTitle = undefined;
        }
        publish();
    });

    pi.on("agent_start", () => {
        agentActive = true;
        publish();
    });

    pi.on("agent_settled", (_event, ctx) => {
        if (ctx?.isIdle?.() !== true) {
            return;
        }
        agentActive = false;
        publish();
        toast("pi: done");
    });
}