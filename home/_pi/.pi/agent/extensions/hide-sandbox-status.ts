import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

// Hides the "🔒 Sandbox: N domains, N write paths" badge from the status
// line without disabling sandboxing. Wraps ctx.ui.setStatus once per session
// so the pi-sandbox extension's writes are filtered in place: no dependence
// on its internals, survives pi-sandbox updates.

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
    ui.setStatus("sandbox", ""); // clear badge set before this hook ran
  });
}