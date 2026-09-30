import { spawn, execSync, type ChildProcess } from "node:child_process";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

// Downloaded with:
//   curl -L -H "Accept: application/octet-stream" \
//     -o ~/.local/share/whisper/models/ggml-large-v3-q8_0.bin \
//     https://api.github.com/repos/sergheinenov/whisper-large-v3-ggml/releases/assets/298763589
const MODEL = `${process.env.HOME}/.local/share/whisper/models/ggml-large-v3-q8_0.bin`;
const WAV = "/tmp/pi-voice.wav";

export default function voice(pi: ExtensionAPI) {
    let recording: ChildProcess | null = null;
    let transcribing = false;

    async function stop(ctx: ExtensionContext) {
        if (!recording) {
            return;
        }
        const child = recording;
        recording = null;
        transcribing = true;
        ctx.ui.setStatus("voice", "transcribing...");
        await new Promise<void>((resolve) => {
            child.once("close", () => resolve());
            child.kill("SIGTERM");
        });
        const text = execSync(
            `whisper-cli -m ${MODEL} -f ${WAV} -nt -np 2>/dev/null`,
            { encoding: "utf8" },
        ).trim();
        transcribing = false;
        ctx.ui.setStatus("voice", undefined);
        if (!text) {
            ctx.ui.notify("No speech detected", "warning");
            return;
        }
        ctx.ui.setEditorText(text);
    }

    pi.registerShortcut("alt+g", {
        description: "Voice: press to start recording, press again to stop and send",
        handler: async (ctx) => {
            if (transcribing) {
                return;
            }
            if (recording) {
                await stop(ctx);
            } else {
                recording = spawn(
                    "parecord",
                    ["--file-format=wav", "--format=s16le", "--rate=16000", "--channels=1", WAV],
                    { stdio: "ignore" },
                );
                ctx.ui.setStatus("voice", "recording (alt+g to stop)");
            }
        },
    });

    pi.on("session_shutdown", () => {
        recording?.kill();
        recording = null;
    });
}
