#!/usr/bin/env bash
# dispatch verify: mechanical checks on one unit. Run from the main checkout.
# Usage: verify.sh <base> <unit> [boundary ...]
# A boundary is a file path, or a directory prefix ending in "/".
# Exit 0 = pass, 1 = fail. Reading the diff and running checks stay with the caller.

set -u
base=${1:?usage: verify.sh <base> <unit> [boundary ...]}
unit=${2:?usage: verify.sh <base> <unit> [boundary ...]}
shift 2

top=$(git rev-parse --show-toplevel)
wt="$(dirname "$top")/$(basename "$top")-$unit"
fail=0
bad() { echo "FAIL: $*"; fail=1; }

[[ -d $wt ]] || { echo "FAIL: no worktree at $wt"; exit 1; }

# Untracked char devices are sandbox dotfile stubs, not worker output.
while IFS= read -r line; do
    path=${line:3}
    [[ $line == '?? '* && -c "$wt/$path" ]] && continue
    bad "worktree not clean: $line"
done < <(git -C "$wt" status --short)

commits=$(git log --oneline "$base..$unit")
[[ -n $commits ]] || bad "no commits on $unit beyond $base"
echo "commits:"; sed 's/^/  /' <<<"$commits"

files=$(git diff --name-only "$base...$unit")
if (($# == 0)); then
    echo "warning: no boundary given, skipping boundary check"
else
    while IFS= read -r f; do
        [[ -n $f ]] || continue
        ok=0
        for b in "$@"; do
            if [[ $b == */ ]]; then [[ $f == "$b"* ]] && ok=1; else [[ $f == "$b" ]] && ok=1; fi
        done
        ((ok)) || bad "outside boundary: $f"
    done <<<"$files"
fi

git diff --stat "$base...$unit"
((fail)) && exit 1
echo "PASS"
