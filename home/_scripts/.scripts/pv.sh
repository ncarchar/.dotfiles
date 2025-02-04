#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
    selected=$1
else
    result=$(find ~/code ~/vault -mindepth 0 -maxdepth 3 -type d -exec test -d '{}/.git' \; -print | fzf --border --expect=esc --ansi --height 40% --preview 'exa --level=1 --icons --tree --git --git-ignore --no-user --no-permissions --group-directories-first {}')

    key=$(head -n 1 <<< "$result")
    selected=$(tail -n +2 <<< "$result")

    if [[ "$key" == "esc" ]]; then
        return 0 || :
    fi
fi

if [[ -z $selected ]]; then
    return 0 || :
fi

cd "$selected" || return 1
echo "Changed directory to: $selected"
