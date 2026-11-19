#!/usr/bin/env bash
# bearings: status of every repo under $BEARINGS_ROOT (default ~/code).
# Prints repos with something in flight or recent pi sessions, newest first;
# quiet repos are counted. shortcut: needs bash 4 (associative arrays), fine under nix.

set -u
root=${BEARINGS_ROOT:-$HOME/code}
sessions=${BEARINGS_SESSIONS:-$HOME/.pi/agent/sessions}
days=${BEARINGS_DAYS:-7}
quiet=0
out=$(mktemp -d); trap 'rm -rf "$out"' EXIT

declare -A s_count s_last s_titles
names=()
for repo in "$root"/*/; do
    [[ -d $repo/.git ]] && names+=("$(basename "$repo")")
done

# Map a session cwd to a repo name; dispatch worktrees (<repo>-<unit>) fold into <repo>.
repo_of() {
    local rel=${1#"$root"/} name best=''
    [[ $1 == "$root"/* ]] || return 1
    name=${rel%%/*}
    for r in "${names[@]}"; do
        if [[ $name == "$r" ]]; then echo "$r"; return; fi
        if [[ $name == "$r"-* && ${#r} -gt ${#best} ]]; then best=$r; fi
    done
    [[ -n $best ]] && echo "$best"
}

while read -r mtime f; do
    [[ -n $f ]] || continue
    info=$(jq -r 'select(.type=="session").cwd, select(.type=="session_info").name' "$f" 2>/dev/null)
    cwd=$(head -n1 <<<"$info")
    r=$(repo_of "$cwd") || continue
    [[ -n $r ]] || continue
    s_count[$r]=$(( ${s_count[$r]:-0} + 1 ))
    [[ -n ${s_last[$r]:-} ]] || s_last[$r]=${mtime%.*}
    title=$(tail -n +2 <<<"$info" | tail -n1); title=${title#π - }
    cur=${s_titles[$r]:-}
    if [[ -n $title && ${#cur} -lt 400 && $cur != *"$title"* ]]; then
        s_titles[$r]="${cur:+$cur|}$title"
    fi
done < <(find "$sessions" -name '*.jsonl' -mtime "-$days" -printf '%T@ %p\n' 2>/dev/null | sort -rn)

for repo in "$root"/*/; do
    repo=${repo%/}
    [[ -d $repo/.git ]] || continue
    branch=$(git -C "$repo" rev-parse --abbrev-ref HEAD 2>/dev/null) || continue
    lines=()

    dirty=$(git -C "$repo" status --porcelain -uno | wc -l)
    ((dirty)) && lines+=("dirty: $dirty tracked file(s)")
    if counts=$(git -C "$repo" rev-list --left-right --count '@{u}...HEAD' 2>/dev/null); then
        read -r behind ahead <<<"$counts"
        ((ahead)) && lines+=("unpushed: $ahead commit(s)")
        ((behind)) && lines+=("behind upstream: $behind")
    fi

    first=1 wt='' wb=''
    while read -r key val; do
        case $key in
            worktree) wt=$val ;;
            branch) wb=${val#refs/heads/} ;;
            '')
                if ((first)); then
                    first=0
                elif [[ -n $wt ]]; then
                    n=$(git -C "$repo" rev-list --count "$branch..${wb:-HEAD}" 2>/dev/null || echo '?')
                    d=$(git -C "$wt" status --porcelain -uno 2>/dev/null | wc -l)
                    lines+=("worktree ${wt##*/} [${wb:-detached}]: $n ahead of $branch, $d dirty")
                fi
                wt='' wb=''
                ;;
        esac
    done < <(git -C "$repo" worktree list --porcelain; echo)

    for plan in "$repo"/__*/PLAN.md; do
        [[ -f $plan ]] || continue
        todo=$(rg -c '^- \[ \]' "$plan" || true)
        wip=$(rg -c '^- \[~\]' "$plan" || true)
        done_=$(rg -c '^- \[x\]' "$plan" || true)
        lines+=("plan ${plan#"$repo"/}: ${done_:-0} done, ${wip:-0} in progress, ${todo:-0} todo")
    done
    for recon in "$repo"/__*/RECON.md; do
        [[ -f $recon ]] && lines+=("recon ${recon#"$repo"/}")
    done

    name=${repo##*/}
    if [[ -n ${s_count[$name]:-} ]]; then
        lines+=("sessions: ${s_count[$name]} in ${days}d, last $(date -d "@${s_last[$name]}" +%F)")
        IFS='|' read -ra ts <<<"${s_titles[$name]:-}"
        for t in "${ts[@]:0:5}"; do lines+=("  - $t"); done
    fi
    if ((${#lines[@]} == 0)); then
        quiet=$((quiet + 1))
        continue
    fi
    { echo "$name ($branch)"; printf '  %s\n' "${lines[@]}"; } >"$out/${s_last[$name]:-0}-$name"
done

# Newest session first; repos with no recent session (key 0) last.
for f in $(ls -r "$out"); do cat "$out/$f"; done

echo "quiet repos: $quiet"
