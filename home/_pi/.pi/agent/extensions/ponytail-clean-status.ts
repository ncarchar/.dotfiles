import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

// Strips the emoji (🐴 and the mode icon ⚡/🌿/🔥) from the ponytail status
// badge so it reads "● ponytail: FULL". Hides the badge entirely unless
// ponytail is actively running: the prefix dot is "●" mid-turn and "○" (or
// empty, mode off) when idle. Wraps ctx.ui.setStatus once per session, so the
// ponytail extension's own writes are sanitized in place — no dependence on
// its internals, survives ponytail updates.

const PICTO = /\p{Extended_Pictographic}/gu;

// ponytail emits: `<indicator> 🐴 ponytail: <icon> <LEVEL>`. The horse sits
// between spaces (keep one), the level icon is followed by a space (drop both).
export function sanitizeStatus(text: string): string {
  return text
    .replace(/ \p{Extended_Pictographic} /gu, " ") // " 🐴 " → " "
    .replace(/\p{Extended_Pictographic} /gu, "") // "⚡ " → ""
    .trim();
}

const wrapped = new WeakSet<object>();

export default function ponytailCleanStatus(pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    const ui = ctx.ui;
    if (!ui || wrapped.has(ui)) return;
    wrapped.add(ui);

    const original = ui.setStatus.bind(ui);
    ui.setStatus = (key, text) => {
      if (key === "ponytail" && typeof text === "string") {
        const cleaned = text.length > 0 ? sanitizeStatus(text) : "";
        // Show only while actually running: the dot is "●" mid-turn, "○" (or
        // empty, mode off) otherwise. Drop everything except the running badge.
        text = cleaned.includes("●") ? cleaned : undefined;
      }
      original(key, text);
    };
  });
}