import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const wrapped = new WeakSet<object>();

export default function hideSandboxStatus(pi: ExtensionAPI) {
    pi.on("session_start", async (_event, ctx) => {
        const ui = ctx.ui;
        if (!ui || wrapped.has(ui)) return;
        wrapped.add(ui);

        const original = ui.setStatus.bind(ui);
        ui.setStatus = (key, text) => {
            if (key === "sandbox") return;
            original(key, text);
        };
        ui.setStatus("sandbox", "");
    });
}
