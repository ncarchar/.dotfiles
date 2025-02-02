#!/usr/bin/env bash

set -e
git --no-pager diff -U0
echo "rebuilding nixos configuration..."
sudo nixos-rebuild switch
gen=$(nixos-rebuild list-generations | grep current)

check=$(git ls-tree -r HEAD | md5sum | awk '{print $1}')

last_commit_msg=$(git log -1 --pretty=%B)
last_hash=$(echo "$last_commit_msg" | awk '{print $1}')

if [[ "$check" == "$last_hash" ]]; then
    echo "no changes - skipping commit..."
else
    echo "committing to git..."
    git add .
    git commit -am "$check $gen"
    git push origin
    echo "commit and push complete..."
fi
