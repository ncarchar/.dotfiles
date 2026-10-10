#!/usr/bin/env bash
# Remove faugus-launcher: runtime data, the nix package, and stale store paths.
# Run OUTSIDE the sandbox: `./remove-faugus.sh`
# Skip the rebuild/gc with: SKIP_REBUILD=1 ./remove-faugus.sh
set -euo pipefail

DIRS=(
    "$HOME/Faugus"
    "$HOME/.config/faugus-launcher"
    "$HOME/.local/share/faugus-launcher"
)

echo "== Faugus runtime data to remove =="
for d in "${DIRS[@]}"; do
    if [ -e "$d" ]; then
        printf '  %-45s %s\n' "$d" "$(du -sh "$d" 2>/dev/null | cut -f1)"
    else
        printf '  %-45s (not found)\n' "$d"
    fi
done

# Flatpak path (only exists if you ever installed the flatpak build; absent here).
FLATPAK="$HOME/.var/app/io.github.Faugus.faugus-launcher"
if [ -e "$FLATPAK" ]; then
    echo "  $FLATPAK  $(du -sh "$FLATPAK" 2>/dev/null | cut -f1)"
    DIRS+=("$FLATPAK")
fi

echo
echo "Removing runtime data..."
for d in "${DIRS[@]}"; do
    if [ -e "$d" ]; then
        echo "  rm -rf $d"
        rm -rf "$d"
    fi
done
echo "Runtime data removed."

if [ "${SKIP_REBUILD:-0}" = "1" ]; then
    echo
    echo "Skipping rebuild and garbage collect (SKIP_REBUILD=1)."
    echo "Run these later to drop the app from the system:"
    echo "  just main"
    echo "  nix-collect-garbage -d"
    echo "  sudo nix-collect-garbage -d"
    exit 0
fi

echo
echo "Rebuilding system to remove the faugus-launcher package (commits packages.nix)..."
just main

echo
echo "Collecting garbage to reclaim store space..."
nix-collect-garbage -d
sudo nix-collect-garbage -d

echo
echo "Done. faugus-launcher is fully removed."
