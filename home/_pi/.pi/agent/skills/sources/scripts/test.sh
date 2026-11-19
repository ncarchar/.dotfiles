#!/usr/bin/env bash
# Test sources.sh against a local bare repo.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
g() { git -c user.name=t -c user.email=t@t "$@"; }
mkdir -p "$t/remote/o" "$t/w" && cd "$t/w" && g init -q -b main
echo 1 >f && g add f && g commit -qm one && g tag v1
echo 2 >f && g commit -qam two
g clone -q --bare . "$t/remote/o/r.git"
export SOURCES_ROOT="$t/cache" SOURCES_BASE="file://$t/remote"

p=$("$here/sources.sh" o/r v1); [[ $(cat "$p/f") == 1 && $p == */r@v1 ]]
p2=$("$here/sources.sh" o/r); [[ $(cat "$p2/f") == 2 && $p2 == */r@HEAD ]]
[[ $("$here/sources.sh" o/r v1) == "$p" ]]                       # reuse
! "$here/sources.sh" o/r nope 2>/dev/null                         # unknown ref
[[ ! -e $SOURCES_ROOT/o/r@nope ]]                                 # no partial dir
! "$here/sources.sh" '../x/y' 2>/dev/null                         # bad repo
! "$here/sources.sh" o/r '--upload-pack=x' 2>/dev/null            # bad ref
touch -d '40 days ago' "$p"; "$here/sources.sh" o/r >/dev/null
[[ ! -e $p ]]                                                     # pruned
echo ok
