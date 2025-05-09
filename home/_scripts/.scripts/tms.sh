#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(find ~/code -mindepth 0 -maxdepth 2 -type d -exec test -d '{}/.git' \; -print | fzf --border --ansi --height 40%  --preview 'exa --level=1 --icons --tree --git --git-ignore --no-user --no-permissions --group-directories-first {}')
fi


if [[ -z $selected ]]; then
    exit 1
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[ -n $tmux_running ]]; then
    tmux attach-session -t $selected_name || tmux new-session -s $selected_name -c $selected
elif [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -s $selected_name -c $selected
else
    if ! tmux has-session -t=$selected_name 2> /dev/null; then
        tmux new-session -ds $selected_name -c $selected
    fi
    tmux switch-client -t $selected_name
fi

tmux switch-client -t $selected_name
