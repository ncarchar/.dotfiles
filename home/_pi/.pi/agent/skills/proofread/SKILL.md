---
name: proofread
description: Fix spelling, grammar, wording, and structure in a block of text, then copy the result to the clipboard. Use when the user asks to clean up, proofread, or fix the wording of some text.
disable-model-invocation: true
---

# proofread

Edit the text passed as arguments for correctness and clarity, then copy the
result to the clipboard and reply with it verbatim.

## Input

Everything after `/proofread` is the text to edit. If it begins with a short
lead-in such as "fix this:" or "please clean up:", ignore the lead-in and edit
only the text that follows. Otherwise treat the whole thing as the text.

If there is no text to edit, ask the user for it.

## Edit rules

- Fix all spelling errors and grammar mistakes.
- Fix awkward or unclear wording.
- Remove redundant statements and repeated ideas.
- Restructure sentences or paragraphs only where it makes the text clearer.
- Otherwise leave the text alone: preserve the author's voice, tone,
  structure, and meaning. Do not over-rework, and do not add new content.
- Never use em dashes or en dashes. Never use semicolons to join clauses.
- Never use emojis.
- Keep the result succinct.

## Output

After editing, do exactly two things:

1. Copy the edited text to the clipboard by piping it into the bundled script
   with a quoted heredoc so the text is passed verbatim:

   ```bash
   scripts/copy.sh <<'EOF'
   <edited text>
   EOF
   ```

   `scripts/copy.sh` resolves the clipboard for this host (Windows clipboard
   on `COV=1`, `wl-copy` otherwise).
2. Confirm the copy succeeded with one short plain line, for example "Copied
   to clipboard."
3. Give a couple of high-level bullets summarizing the main changes you made.
   Keep it to the main points only, not an exhaustive list.
4. Reply with the edited text, verbatim, as raw plain text. No markdown, no
   code fences, no headings, no bullet points, nothing but the text itself.