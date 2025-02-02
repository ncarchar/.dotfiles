#!/usr/bin/env bash

set -e
git --no-pager diff -U0 *.nix
echo "rebuilding nixos configuration..."
sudo nixos-rebuild switch
gen=$(nixos-rebuild list-generations | grep current)

echo "commiting to git..."
check=$(tar -cf - ./ | md5sum);
git add .
git commit -am "$check$gen"
echo "complete"
