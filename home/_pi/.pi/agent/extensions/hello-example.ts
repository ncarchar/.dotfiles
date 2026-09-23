import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

// Minimal example extension. Copy this file to start a new extension, or
// delete it once you have your own. Auto-discovered from
// ~/.pi/agent/extensions/ (symlinked to ~/.dotfiles/home/_pi/.pi/agent/extensions/).

export default function (pi: ExtensionAPI) {
  // React to lifecycle events.
  pi.on("session_start", async (_event, ctx) => {
    ctx.ui.notify("hello-example extension loaded", "info");
  });

  // Register a tool the LLM can call.
  pi.registerTool({
    name: "greet",
    label: "Greet",
    description: "Greet someone by name",
    parameters: Type.Object({
      name: Type.String({ description: "Name to greet" }),
    }),
    async execute(_toolCallId, params, _signal, _onUpdate, _ctx) {
      return {
        content: [{ type: "text", text: `Hello, ${params.name}!` }],
        details: {},
      };
    },
  });

  // Register a slash command: /hello-ext
  pi.registerCommand("hello-ext", {
    description: "Say hello from the example extension",
    handler: async (args, ctx) => {
      ctx.ui.notify(`Hello${args ? `, ${args}` : ""}!`, "info");
    },
  });
}
