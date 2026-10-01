import { spawn, execSync, type ChildProcess } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

// q5_0 is the default (size/quality sweet spot); q8_0 for max quality.
// small-q8_0 (~244MB) is the only smaller option and comes with a real quality drop.
const MODEL_DIR = `${process.env.HOME}/.local/share/whisper/models`;
const MODEL_NAMES = [
    "ggml-large-v3-turbo-q8_0.bin",
    "ggml-large-v3-turbo-q5_0.bin",
    "ggml-small-q8_0.bin",
];
const ACTIVE_FILE = `${MODEL_DIR}/active.txt`;
const WAV = "/tmp/pi-voice.wav";
const DOWNLOADS = MODEL_NAMES.map(
    (name) => `mkdir -p ~/.local/share/whisper/models && cd ~/.local/share/whisper/models && curl -L -o ${name} "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/${name}"`,
);

const modelPath = (name: string) => `${MODEL_DIR}/${name}`;

let modelName = (() => {
    try {
        const saved = readFileSync(ACTIVE_FILE, "utf8").trim();
        if (MODEL_NAMES.includes(saved)) {
            return saved;
        }
    } catch {
        // first run, no saved choice
    }
    return MODEL_NAMES[1];
})();

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
            `whisper-cli -m ${modelPath(modelName)} -f ${WAV} -nt -np 2>/dev/null`,
            { encoding: "utf8" },
        ).trim();
        transcribing = false;
        ctx.ui.setStatus("voice", undefined);
        if (!text) {
            ctx.ui.notify("No speech detected", "warning");
            return;
        }
        try {
            pi.sendUserMessage(text);
        } catch {
            pi.sendUserMessage(text, { deliverAs: "steer" });
        }
    }

    async function toggle(ctx: ExtensionContext) {
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
            ctx.ui.setStatus("voice", "recording (/voice or alt+g to stop)");
        }
    }

    pi.registerShortcut("alt+g", {
        description: "Voice: press to start recording, press again to stop and submit",
        handler: toggle,
    });

    pi.registerCommand("voice", {
        description: "Voice: start/stop recording and transcribe",
        handler: async (_args, ctx) => {
            await toggle(ctx);
        },
    });

    pi.registerCommand("voice-help", {
        description: "Show the command to download the whisper model",
        handler: async (_args, ctx) => {
            ctx.ui.notify(DOWNLOADS.join("\n"), "info");
        },
    });

    pi.registerCommand("voice-model", {
        description: "Choose the whisper model used for transcription",
        handler: async (_args, ctx) => {
            const choice = await ctx.ui.select("Whisper model:", MODEL_NAMES);
            if (!choice) {
                return;
            }
            modelName = choice;
            mkdirSync(MODEL_DIR, { recursive: true });
            writeFileSync(ACTIVE_FILE, `${modelName}\n`);
            const downloaded = existsSync(modelPath(modelName));
            ctx.ui.notify(
                downloaded ? `Voice model: ${modelName}` : `${modelName} not downloaded yet (see /voice-help)`,
                downloaded ? "info" : "warning",
            );
        },
    });

    pi.on("session_shutdown", () => {
        recording?.kill();
        recording = null;
    });
}
