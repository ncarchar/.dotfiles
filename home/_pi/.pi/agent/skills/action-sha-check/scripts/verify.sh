#!/usr/bin/env bash
# action-sha-check: verify GitHub Actions "uses:" pins are valid commit SHAs.
# Dependencies: curl + jq only. Uses the GitHub REST API (git ls-remote is
# HTTPS-blocked here), so keep it that way.

set -u

RESOLVE=0
paths=()

usage() {
    cat <<'EOF'
Usage: verify.sh [--resolve] [FILE|DIR ...]

Verifies "uses:" pins in GitHub Actions workflows are real commit SHAs.

  --resolve      Resolve floating tag refs (e.g. @v6) to their peeled commit SHA.
  FILE|DIR       Files or directories to scan (default: .github/).

Environment:
  GITHUB_TOKEN / GH_TOKEN   Add an Authorization header (private repos and to
                            avoid the 60/hr unauthenticated rate limit).

Exit status: non-zero if any pin is invalid (MISMATCH, unpinned, or unresolved).
EOF
}

for arg in "$@"; do
    case "$arg" in
        --resolve)
            RESOLVE=1
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            paths+=("$arg")
            ;;
    esac
done
[ "${#paths[@]}" -eq 0 ] && paths=(.github)

AUTH=()
if [ -n "${GITHUB_TOKEN:-}" ]; then
    AUTH=(-H "Authorization: Bearer $GITHUB_TOKEN")
elif [ -n "${GH_TOKEN:-}" ]; then
    AUTH=(-H "Authorization: Bearer $GH_TOKEN")
fi

# GET a URL, print the raw JSON body. Non-2xx still yields whatever GitHub
# returns, so jq below can read ".sha"/".object" or the error "message".
api() {
    curl -sS "${AUTH[@]}" "$1"
}

# index: the body of a /git/ref/tags/<tag> or /git/tags/<sha> response.
peel_index() { jq -r '.object.type // empty' <<<"$1"; }
object_sha() { jq -r '.object.sha // empty' <<<"$1"; }

# Resolve a tag name to its peeled commit SHA. Handles both lightweight tags
# (.object.type == "commit") and annotated tags (.object.type == "tag", which
# must be peeled a second time through /git/tags/<sha> to reach the commit).
resolve_tag() {
    local repo="$1" tag="$2" ref type sha
    ref=$(api "https://api.github.com/repos/$repo/git/ref/tags/$tag")
    type=$(peel_index "$ref")
    sha=$(object_sha "$ref")
    [ -z "$sha" ] && return 1
    if [ "$type" = "tag" ]; then
        sha=$(api "https://api.github.com/repos/$repo/git/tags/$sha" | object_sha)
    fi
    [ -n "$sha" ] || return 1
    printf '%s' "$sha"
}

# True when $2 is a real commit SHA of $1.
commit_exists() {
    local repo="$1" sha="$2" got
    got=$(api "https://api.github.com/repos/$repo/commits/$sha" | jq -r '.sha // empty')
    [ -n "$got" ] && [ "${got,,}" = "${sha,,}" ]
}

is_sha() { [[ "$1" =~ ^[0-9a-fA-F]{40}$ ]]; }

# Print the files (yml/yaml) under the requested paths to scan.
list_files() {
    local p
    for p in "$@"; do
        if [ -d "$p" ]; then
            find "$p" -type f \( -name '*.yml' -o -name '*.yaml' \)
        elif [ -f "$p" ]; then
            printf '%s\n' "$p"
        fi
    done
}

is_local_action() { [[ "$1" == ./* ]] || [[ "$1" == ../* ]] || [[ "$1" == docker://* ]]; }

fail=0

while IFS= read -r f; do
    while IFS= read -r entry; do
        lineno=${entry%%:*}
        content=${entry#*:}

        # Extract the first token after "uses:" (allow optional quotes).
        target=""
        if [[ "$content" =~ uses:[[:space:]]*(.+)$ ]]; then
            target=${BASH_REMATCH[1]}
            target=${target%%[[:space:]]*}
            target=${target#\"}; target=${target#\'}
            target=${target%\"}; target=${target%\'}
        fi
        [ -n "$target" ] || continue
        is_local_action "$target" && continue

        repo=""; ref=""
        case "$target" in
            *@*)
                ref=${target##*@}
                repo=${target%@*}
                ;;
            *)
                repo="$target"
                ;;
        esac

        here="$f:$lineno"

        if is_sha "$ref"; then
            if [ -n "$repo" ] && commit_exists "$repo" "$ref"; then
                printf 'MATCH    %s  (%s)\n' "$target" "$here"
            else
                printf 'MISMATCH %s  (%s)\n' "$target" "$here"
                fail=1
            fi
            continue
        fi

        # Non-SHA ref: branch name, missing version, or a floating tag.
        if [ "$RESOLVE" -eq 1 ]; then
            if [ -z "$ref" ]; then
                printf 'UNPINNED %s  (missing @version) (%s)\n' "$target" "$here"
                fail=1
            elif [ -n "$repo" ] && sha=$(resolve_tag "$repo" "$ref"); then
                printf 'RESOLVED %s -> %s  (%s)\n' "$target" "$sha" "$here"
            else
                printf 'UNPINNED %s  (not a resolvable tag) (%s)\n' "$target" "$here"
                fail=1
            fi
        else
            printf 'UNPINNED %s  (%s)\n' "$target" "$here"
            fail=1
        fi
    done < <(grep -nE '^[[:space:]]*-?[[:space:]]*uses:[[:space:]]*[^[:space:]]' "$f" || true)
done < <(list_files "${paths[@]}")

exit "$fail"