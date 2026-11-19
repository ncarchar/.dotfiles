#!/usr/bin/env bash
# Test verify.sh and merge.sh in a throwaway repo.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
g() { git -c user.name=t -c user.email=t@t "$@"; }
mkdir "$t/r" && cd "$t/r" && g init -q -b main && mkdir src && echo 0 >src/a && g add . && g commit -qm init

g worktree add -q -b u1 ../r-u1 main
echo 1 >../r-u1/src/a && echo x >../r-u1/other
g -C ../r-u1 add . && g -C ../r-u1 commit -qm w

! "$here/verify.sh" main u1 src/ >/dev/null || { echo "boundary breach not caught"; exit 1; }
"$here/verify.sh" main u1 src/ other >/dev/null
echo dirty >../r-u1/src/a
! "$here/verify.sh" main u1 src/ other >/dev/null || { echo "dirty not caught"; exit 1; }
g -C ../r-u1 checkout -q src/a

echo m >m && g add m && g commit -qm moved
"$here/merge.sh" main u1 &>/dev/null && exit 1 || [[ $? == 2 ]]   # base moved

g -C ../r-u1 rebase -q main
"$here/merge.sh" main u1 >/dev/null
[[ ! -d ../r-u1 ]] && [[ $(cat src/a) == 1 ]]
echo ok
