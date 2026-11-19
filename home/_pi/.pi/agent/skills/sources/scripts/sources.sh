#!/usr/bin/env bash
# Usage: sources.sh <owner/name> [ref]
# Shallow-clones a public GitHub repo into a temp cache and prints its path.
# Reuses an existing clone; deletes clones unused for SOURCES_DAYS (default 30).
# shortcut: ref must be a branch or tag (no commit SHA), upgrade to fetch-by-SHA if needed.
set -eu
root="${SOURCES_ROOT:-$HOME/.cache/pi-sources}"
base="${SOURCES_BASE:-https://github.com}"
repo="${1:-}"; ref="${2:-}"

[[ $repo =~ ^[A-Za-z0-9._-]+/[A-Za-z0-9._-]+$ && $repo != *..* ]] || { echo "bad repo '$repo', want owner/name" >&2; exit 1; }
[[ -z $ref || ( $ref =~ ^[A-Za-z0-9._/-]+$ && $ref != -* && $ref != *..* ) ]] || { echo "bad ref '$ref'" >&2; exit 1; }

mkdir -p "$root"
find "$root" -mindepth 2 -maxdepth 2 -type d -name '*@*' -mtime "+${SOURCES_DAYS:-30}" -exec rm -rf {} +

dir="$root/${repo%/*}/${repo#*/}@$(echo "${ref:-HEAD}" | tr / -)"
if [[ -d $dir ]]; then
    touch "$dir"
    echo "$dir"
    exit 0
fi

tmp=$(mktemp -d "$root/.tmp.XXXXXX"); trap 'rm -rf "$tmp"' EXIT
url="$base/$repo.git"
if ! GIT_TERMINAL_PROMPT=0 git -c advice.detachedHead=false clone -q --depth 1 ${ref:+--branch "$ref"} "$url" "$tmp/c" >&2; then
    echo "clone failed (private repo or unknown ref?). Tags: git ls-remote --tags $url | rg '$ref'" >&2
    exit 1
fi
mkdir -p "$(dirname "$dir")" && mv "$tmp/c" "$dir"
echo "$dir"
