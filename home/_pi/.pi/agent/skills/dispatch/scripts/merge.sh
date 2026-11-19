#!/usr/bin/env bash
# dispatch merge: fast-forward a verified unit into the base and clean up.
# Usage: merge.sh <base> <unit> [--keep]    (--keep skips worktree and branch removal)
# Run from the main checkout. Exit 2 = base moved or not checked out; ask the user.

set -eu
base=${1:?usage: merge.sh <base> <unit> [--keep]}
unit=${2:?usage: merge.sh <base> <unit> [--keep]}
keep=${3:-}

top=$(git rev-parse --show-toplevel)
wt="$(dirname "$top")/$(basename "$top")-$unit"

[[ $(git rev-parse --abbrev-ref HEAD) == "$base" ]] || { echo "not on $base"; exit 2; }
old=$(git rev-parse HEAD)
git merge --ff-only "$unit" || { echo "ff-only failed: $base moved. Rebase $unit or merge normally (ask the user)."; exit 2; }

if [[ $keep != --keep ]]; then
    git worktree remove "$wt"
    git branch -d "$unit"
fi
git log --oneline "$old..HEAD"
