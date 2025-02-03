#!/usr/bin/env bash

set -e

git --no-pager diff -U0

if [[ -f "/etc/NIXOS" ]]; then
    echo "rebuilding nixos configuration..."
    sudo nixos-rebuild switch
    gen=$(nixos-rebuild list-generations | grep current)
else
    echo "upgrading sys packages..."
    gen="__"
fi

if [[ -n $(git status --porcelain) ]]; then
    check=$(git ls-tree -r HEAD | md5sum | awk '{print $1}')
    echo "committing to git..."
    git add .
    git commit -am "$check $gen"
    git push origin
    echo "commit and push complete..."
else
    echo "no changes - nothing to commit..."
fi
