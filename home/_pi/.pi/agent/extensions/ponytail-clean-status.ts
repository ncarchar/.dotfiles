import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

// Hides the ponytail status badge entirely. Wraps ctx.ui.setStatus once per
// session so the ponytail extension's own writes are dropped in place.

const wrapped = new WeakSet<object>();

export default function ponytailCleanStatus(pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    const ui = ctx.ui;
    if (!ui || wrapped.has(ui)) return;
    wrapped.add(ui);

    const original = ui.setStatus.bind(ui);
    ui.setStatus = (key, text) => {
      if (key === "ponytail") {
        text = undefined;
      }
      original(key, text);
    };
  });
}