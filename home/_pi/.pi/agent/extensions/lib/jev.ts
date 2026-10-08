/*
 * Shared helper for TypeSafe Jev decisions via OpenRouter's Decisions API.
 *
 * Plain module (no default export) so pi does not auto-load it as an
 * extension. Extensions import { decide } from "./lib/jev".
 *
 * API: POST https://openrouter.ai/api/alpha/decisions
 * Body: { model, state, questions } -> { answers, usage }
 * Jev returns typed decisions (noul/choice/score) with probabilities, no prose.
 */

export type JevQuestion =
    | { type: "noul"; instructions: string; criteria?: Record<string, string> }
    | { type: "choice"; instructions: string; criteria: Record<string, string> }
    | { type: "score"; instructions: string; criteria: string[] };

export interface NoulAnswer {
    type: "noul";
    noul: number;
}

export interface ChoiceAnswer {
    type: "choice";
    choice: string;
    confidence: number;
    probabilities: Record<string, number>;
}

export interface ScoreAnswer {
    type: "score";
    score: number;
    confidence: number;
    probabilities: Record<string, number>;
    legend?: Record<string, string>;
}

export type JevAnswer = NoulAnswer | ChoiceAnswer | ScoreAnswer;

export interface JevResult {
    answers: Record<string, JevAnswer>;
    cost: number;
}

export class JevError extends Error {
    readonly status: number;
    readonly detail: string;

    constructor(status: number, body: string) {
        super(`jev HTTP ${status}`);
        this.name = "JevError";
        this.status = status;
        this.detail = body.slice(0, 500);
    }
}

const DECISIONS_URL = "https://openrouter.ai/api/alpha/decisions";

export async function decide(
    state: unknown,
    questions: Record<string, JevQuestion>,
    model = "typesafe/jev-1.13",
    timeoutMs = 15000,
): Promise<JevResult> {
    const key = process.env.OPENROUTER_API_KEY;
    if (!key) throw new Error("OPENROUTER_API_KEY is not set");

    const res = await fetch(DECISIONS_URL, {
        method: "POST",
        headers: {
            Authorization: `Bearer ${key}`,
            "Content-Type": "application/json",
        },
        body: JSON.stringify({ model, state, questions }),
        signal: AbortSignal.timeout(timeoutMs),
    });

    if (!res.ok) throw new JevError(res.status, await res.text());

    const body = (await res.json()) as {
        answers: Record<string, JevAnswer>;
        usage?: { cost?: number };
    };
    return { answers: body.answers, cost: body.usage?.cost ?? 0 };
}
