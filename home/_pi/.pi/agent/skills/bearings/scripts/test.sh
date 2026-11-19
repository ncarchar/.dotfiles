#!/usr/bin/env bash
# Smoke test: one dirty repo, one quiet repo.
set -eu
t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
for r in dirty quiet; do
    git init -q "$t/$r" && git -C "$t/$r" -c user.name=t -c user.email=t@t commit -q --allow-empty -m init
done
echo a >"$t/dirty/f" && git -C "$t/dirty" add f && git -C "$t/dirty" -c user.name=t -c user.email=t@t commit -qm f && echo b >"$t/dirty/f"
mkdir "$t/dirty/__x" && printf -- '- [x] a\n- [ ] b\n' >"$t/dirty/__x/PLAN.md"
mkdir -p "$t/s/x"
printf '{"type":"session","cwd":"%s"}\n{"type":"session_info","name":"π - old title"}\n{"type":"session_info","name":"π - wiring"}\n' "$t/quiet-feat" >"$t/s/x/a.jsonl"
out=$(BEARINGS_ROOT=$t BEARINGS_SESSIONS=$t/s "$(dirname "$0")/bearings.sh")
grep -q 'dirty: 1' <<<"$out" && grep -q '1 done, 0 in progress, 1 todo' <<<"$out" && grep -q 'quiet repos: 0' <<<"$out"
# worktree session folds into quiet repo, newest first, last title wins
grep -q 'sessions: 1 in 7d' <<<"$out" && grep -q '    - wiring' <<<"$out" && [[ $(head -1 <<<"$out") == quiet* ]]
echo ok
