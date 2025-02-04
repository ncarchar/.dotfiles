#!/bin/sh

export PATH="$HOME/.scripts:$PATH"

source ~/.shell/alias.sh

export HOSTNAME=$(hostname)
HOSTNAME=$HOSTNAME

BLUE='\e[1;34m'
CYAN='\e[1;36m'
GREEN='\e[1;32m'
RED='\e[1;31m'
YELLOW='\e[1;33m'

RESET='\e[0m'

parse_git_branch() {
  branch=$(git branch --show-current 2>/dev/null)
  if [[ -n "$branch" ]]; then
    dirty=""
    if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
      dirty=" ${YELLOW}✗${RESET}"
    fi
    echo -e " ${BLUE}git:(${RED}${branch}${BLUE})${dirty}${RESET}"
  fi
}

export PS1=" ${CYAN}\W\$(parse_git_branch) ${RESET}"

if [[ -n "$IN_NIX_SHELL" ]]; then
    export PS1="(nix) $PS1"
fi
