#!/usr/bin/env bash
set -euo pipefail

# Copy stdin to this host's clipboard.
# COV=1 (work machine, WSL): Windows clipboard via clip.exe.
# Otherwise: Wayland clipboard via wl-copy.
if [[ "${COV:-}" == "1" ]]; then
    exec /mnt/c/WINDOWS/system32/clip.exe
else
    exec wl-copy
fi