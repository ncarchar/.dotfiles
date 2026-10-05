# GlazeWM + herdr stray-key bug (herdr issue #3316)

Handoff notes for the agent that picks this up. Everything needed to understand the
bug, reproduce it, and push the upstream fix forward.

## TL;DR

- Symptom: focus a herdr window from GlazeWM with `alt+h` and a stray `h` is typed
  into the focused pane. Same for `alt+j/k/l` (stray j/k/l) and `alt+1..9` (stray
  digit). Only herdr is affected. tmux and a bare shell are not.
- Root cause: GlazeWM's low-level keyboard hook swallows the key *down* of `alt+h`
  and moves focus, but Windows still delivers the `h` keydown to the terminal when it
  regains focus. The outer terminal turns that into a literal `h` byte only because
  herdr has keyboard-enhancement protocols active (kitty keyboard protocol + focus
  reporting). herdr faithfully forwards a byte it cannot tell apart from a real keypress.
- Status: known upstream, tracked in herdr issue #3316, currently CLOSED (NOT_PLANNED)
  because the reporter never returned the byte capture the maintainer asked for.
- Done so far: we produced that exact capture. It is decoded and interpreted below.
  What remains is to gather a few version strings and post the capture upstream.

## Links

- herdr issue #3316 (the bug): https://github.com/herdrdev/herdr/issues/3316
- New issue form: https://github.com/herdrdev/herdr/issues/new
- Related upstream (see the "Related issues and PRs" section for details).

## Symptom

In GlazeWM, focus/workspace navigation is bound to `alt+<key>` (see the user's
GlazeWM config below). When such a binding moves focus *into* a window running
herdr, the non-modifier character of the chord is typed into herdr's focused pane:

- `alt+h` -> stray `h`
- `alt+3` (focus workspace 3) -> stray `3`
- and so on for every alt-letters/digits binding.

What the user already established:

- Only herdr shows the stray char. A bare terminal and tmux do not.
- Confirmed with `stty raw -echo; timeout 15 cat -v; stty sane`: outside herdr no
  byte arrives at all.
- Rebinding GlazeWM is off the table for the user.
- Binding overlapping keys in herdr did not help (see "Why that cannot work").

## Environment

Known (from this repo / machine):

- Dotfiles repo, GNU stow, Nix flake. Machine is WSL (Debian per AGENTS.md).
- herdr is installed as a Linux x86-64 ELF via Nix. Nix store shows herdr 0.9.1.
- herdr config: `~/.config/herdr/config.toml` is a stow symlink to
  `~/.dotfiles/home/_herdr/.config/herdr/config.toml`.

Assumption to confirm with the user (matters for the maintainer): the affected herdr
session runs under WSL (Linux herdr inside a Windows Terminal / Alacritty / WezTerm
window), with GlazeWM on the Windows side tiling that terminal window. All evidence
in this repo points to that, but confirm it is not native-Windows herdr.

Still needed before posting (ask the user or detect):

- `herdr -V` (installed version; repo shows 0.9.1, latest stable is 0.9.3).
- Outer terminal name and version (Windows Terminal / Alacritty / WezTerm / other).
  Detect hints in WSL env: `$WT_SESSION` (Windows Terminal), `$ALACRITTY_WINDOW_ID`
  (Alacritty), `$TERM_PROGRAM`, `$TERM`.
- WSL distro and version (`cat /etc/os-release`, `uname -a`).
- Windows version (`11` assumed; get exact build).
- GlazeWM version (issue #3316 reporter was on 3.10.1; must be collected on the
  Windows side, e.g. `glazewm --version` in PowerShell).

## Relevant config

### GlazeWM (user's own, on Windows)

Relevant bindings (complete file was pasted in the session; only the leak-relevant
part is summarized):

```yaml
keybindings:
  - commands: ["focus --direction left"]     bindings: ["alt+h", "alt+left"]
  - commands: ["focus --direction down"]     bindings: ["alt+j", "alt+down"]
  - commands: ["focus --direction up"]       bindings: ["alt+k", "alt+up"]
  - commands: ["focus --direction right"]    bindings: ["alt+l", "alt+right"]
  - commands: ["move --direction ..."]       bindings: ["alt+shift+h/j/k/l", ...]
  - commands: ["move-workspace --direction ..."] bindings: ["alt+shift+a/f/d/s"]
  - commands: ["focus --workspace 1..9"]     bindings: ["alt+1" .. "alt+9"]
  - commands: ["move --workspace N", "focus --workspace N"] bindings: ["alt+shift+1..9"]
  # plus alt+z fullscreen, alt+shift+p pause, alt+v tiling dir, alt+space cycle, etc.
```

Invariant: the leaked character equals the non-modifier key of whatever chord was
pressed (h for alt+h, 3 for alt+3). Any `alt+<literal>` binding will leak its literal.

### herdr config (`~/.dotfiles/home/_herdr/.config/herdr/config.toml`)

```toml
onboarding = false

[keys]
prefix = "ctrl+space"
new_tab = ["prefix+c", "ctrl+t"]
close_tab = ["prefix+shift+x", "ctrl+w"]
next_tab = ["prefix+n", "ctrl+tab"]
previous_tab = ["prefix+p", "ctrl+shift+tab"]
new_workspace = ["prefix+shift+n", "ctrl+shift+t"]
close_workspace = ["prefix+shift+d", "ctrl+shift+w"]
switch_workspace = "prefix+shift+1..9"

[ui]
confirm_close = true
prompt_new_tab_name = false

[ui.sidebar.agents.rows_by_agent]
pi = [
  ["state_icon", "workspace"],
  ["terminal_title_stripped"],
]
```

Confirmed: there is no herdr config key to disable the kitty keyboard protocol or
keyboard-enhancement input. The full canonical config reference (v0.9.3) has no such
key. The only nearby keys are `terminal.kitty_graphics` (graphics, irrelevant),
`ui.redraw_on_focus_gained`, and unrelated `experimental.*`. A strings search of the
binary found no `HERDR_*` env var for keyboard/kitty input either.

## Root cause analysis

Two hypotheses over the course of the investigation:

### Hypothesis 1 (maintainer's guess in #3316): release misfire

Maintainer thought the outer terminal reports the leaked key *release* as a kitty
`CSI <code>;1u` sequence, and herdr mis-translates that release into a printable byte
for a legacy (non-kitty) inner pane instead of dropping it.

### Hypothesis 2 (proved by our capture): spurious keydown on focus-gain

The capture below disproves Hypothesis 1. The terminal emits a bare printable `h`
keydown (no kitty encoding, no matching press/release pair) immediately after the
focus-gained escape `CSI I`. Sequence:

1. GlazeWM low-level keyboard hook (WH_KEYBOARD_LL) swallows the `alt+h` keydown and
   switches focus to the terminal window.
2. Windows still delivers the (held) `h` keydown to the newly focused window.
3. The outer terminal emits that keydown as a literal `h` byte, but only because the
   PTY has keyboard enhancement active (kitty keyboard protocol / focus reporting,
   both of which herdr enables).
4. herdr forwards the byte to the focused pane; it is indistinguishable from a real
   typed `h`.

This exactly explains the asymmetry the user reported:

- Bare shell (no protocol negotiated): the terminal discards the spurious keydown, so
  `stty raw; cat -v` prints nothing.
- tmux (does not negotiate these protocols with the outer terminal): also immune.
- herdr (negotiates them): the terminal emits the byte, herdr forwards it.

Why the user's attempted workarounds cannot work:

- Binding `alt+h` in herdr: GlazeWM consumes `alt+h` before herdr sees it, and the
  leaked event is a bare `h`, not an alt+h press.
- There is no "capture all keys" or "drop stray keys" option; herdr keybindings match
  presses, not this leaked keydown, and the byte reaches the pane as ordinary input.

## The decisive capture

Run OUTSIDE herdr, in the same outer terminal / WSL window. Script (kept here verbatim
so it can be rerun):

```python
import os, select, sys, termios, time, tty
fd, out = sys.stdin.fileno(), sys.stdout.fileno()
old = termios.tcgetattr(fd)
data = bytearray()
print("switch away, then return with alt+h while holding h", flush=True)
time.sleep(1)
try:
    tty.setraw(fd)
    termios.tcflush(fd, termios.TCIFLUSH)
    os.write(out, b"\x1b[?1004h\x1b[>7u")
    deadline = time.monotonic() + 15
    while time.monotonic() < deadline:
        ready, _, _ = select.select([fd], [], [], deadline - time.monotonic())
        if ready:
            data.extend(os.read(fd, 4096))
finally:
    os.write(out, b"\x1b[<u\x1b[?1004l")
    termios.tcsetattr(fd, termios.TCSADRAIN, old)
print("\ncaptured:", repr(bytes(data)))
```

Notes on the modes the script enables (these are what herdr enables in real use):

- `?1004h` - focus reporting (terminal sends `CSI I` on focus gained, `CSI O` on lost).
- `>7u` - kitty keyboard protocol flags: 1 disambiguate + 2 report event types +
  4 report alternate keys.

Raw captured output (verbatim):

```
captured: b'\x1b[Ih\x1b[O\x1b[Ih\x1b[O\x1b[Ih\x1b[O\x1b[Ih\x1b[99;5:1u\x1b[99;5:3u\x1b[99;5:1u\x1b[99;5:3u\x1b[99;5:1u\x1b[99;5:3u\x1b[O\x1b[Ih\x1b[O'
```

Decoded:

```
\x1b[I          = CSI I  -> focus gained
h               = bare 'h' byte (leaked keydown, no kitty encoding)
\x1b[O          = CSI O  -> focus lost
\x1b[99;5:1u    = keycode 99 ('c'), modifier 5 (shift+ctrl), event 1 (press)
\x1b[99;5:3u    = same key, event 3 (release)
```

Full sequence, split per cycle:

```
cycle: CSI I , h , CSI O
cycle: CSI I , h , CSI O
cycle: CSI I , h , CSI O
cycle: CSI I , h , (CSI 99;5:1u , CSI 99;5:3u) x3 , CSI O
cycle: CSI I , h , CSI O
```

Five focus-gain events, each immediately followed by a bare `h`. The three
`99;5:1u/3u` pairs are the user's own ctrl+shift+C (copy) presses and are unrelated.

Interpretation for the issue:

- The leaked event is a plain printable keydown emitted at focus-gain, with no kitty
  press/release encoding and no matching press. It is not a `CSI-u` release leak.
- It appears only when keyboard/focus protocols are enabled, which is why herdr alone
  is affected.
- The likely fix location is the outer terminal (do not emit a keydown byte for a key
  that was never pressed into the focused window) or herdr (drop printable bytes that
  follow `CSI I` with no matching press). GlazeWM-side suppression of the keyup/keydown
  would also remove it, but the user has ruled out rebinding GlazeWM.

## Related upstream issues and PRs (status as of this handoff)

- #3316 "Stray printable byte injected on key-release under Kitty keyboard protocol
  when focus is gained mid-keypress (tiling WM workspace switch)" - CLOSED (NOT_PLANNED).
  Reporter env: Windows 11 + WSL2 Arch, GlazeWM 3.10.1, Alacritty 0.17.0, herdr 0.8.2.
  Closed 2026-09-03 by a bot after the maintainer's capture request timed out
  (7-day reporter timeout). This is the issue to update/reopen.
- #1746 "Printable-key release events are missing with Kitty keyboard protocol"
  - closed. The "expected release sequence is dropped" reference the maintainer cited.
- #4184 "Printable-key releases missing again for typed keys" - open.
- #4365 "Windows: Kitty key-release sequences leak as literal text into jcode pane"
  - open. Evidence the release-leak class also exists on native Windows.
- #4856 "Windows Alacritty -> SSH -> Linux Herdr: Kitty key-release fragments
  (`1:3u`, `:3u`) leak as literal text into panes (Alacritty 0.17.0)" - open.
- #3546 "Windows: dead-key circumflex (Shift+6) leaks a stray '6' when the pane app
  enables the kitty keyboard protocol" - closed. Broader class: any printable key
  mishandled under kitty protocol.
- PR #4742 "fix: forward printable key releases through client shell input routing"
  - closed, NOT merged (refs #4184).
- PR #3548 "fix(windows): preserve dead-key composition in kitty panes" - merged
  2026-09-02, base master.

Release timeline: v0.9.1 2026-09-16, v0.9.2 and v0.9.3 2026-09-29. As of the latest
stable (0.9.3) there is no fix for this specific bug.

## Recommended next steps for the agent

1. Gather the missing version info listed in the Environment section and confirm the
   WSL-vs-native-Windows assumption with the user.
2. Confirm `herdr update` has been tried and the bug still reproduces on latest stable.
3. Post the capture upstream. Because #3316 was auto-closed by a bot, the cleanest path
   is a NEW issue linking #3316. Suggested title and body below.
4. Keep the captured bytes and the decoded explanation verbatim in the post; that is
   exactly the data the maintainer asked for and never received.

### Draft issue body (fill bracketed values before posting)

```
## Environment
- OS: [Windows version] + WSL2 [distro] (confirm: herdr runs as the Linux build in WSL)
- Window manager: GlazeWM [version] (focus bound to alt+h/j/k/l, workspaces alt+1..9)
- Outer terminal: [name] [version]
- herdr: [herdr -V]

## Summary
Focusing a herdr window from GlazeWM via alt+<key> types the literal key into the
focused pane (alt+h -> h, alt+3 -> 3). Bare shell and tmux are unaffected. Only herdr.

## Repro
1. GlazeWM with alt+h bound to focus --direction left, the target window running herdr.
2. From another window/app, press alt+h.
3. A stray h lands in herdr's focused pane. In a pane: stty raw -echo; cat -v shows
   a bare h with no preceding escape sequence.

## Capture (outside herdr, same terminal, protocols enabled)
<the python script>
Raw: <the captured: line>
Decoded: five CSI I (focus gained) each immediately followed by a bare h, then CSI O
(focus lost). No kitty press/release encoding and no matching press for the h.

## Analysis
This refines #3316. It is not a CSI-u release mis-translation: the outer terminal
emits a bare printable keydown at focus-gain, and only because keyboard/focus
protocols are active. herdr forwards a byte indistinguishable from a real keypress.
Bare shell/tmux do not negotiate these protocols, so the terminal discards the event.

Links: #3316 (previous report, closed for missing capture), #1746, #4184, #4856.
```

### If a comment on #3316 is preferred instead

Reply to #3316 with the "Capture" and "Analysis" sections above, noting the reporter
never returned the capture and this provides it. Ask the maintainer if the report can
be reactivated or if a new issue is preferable.

## Open questions / caveats

- Confirm WSL vs native-Windows herdr. The repo evidence (Nix Linux ELF, WSL dotfiles)
  says WSL, but ask the user before asserting it publicly.
- The exact Windows mechanism (why Windows redelivers the held keydown to the newly
  focused window) is not pinned down; it does not block the fix, which is terminal- or
  herdr-side regardless.
- Whether the maintainer prefers a terminal-level check over a herdr-side workaround
  is their call; the report should present the capture and let them decide.