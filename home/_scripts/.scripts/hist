#!/usr/bin/env bash

 HISTFILE="$HOME/.zsh_history"
 if [[ ! -f "$HISTFILE" ]]; then
   echo "History file not found: $HISTFILE"
   exit 1
 fi

selected=$(history | awk '{$1=""; print substr($0,2)}' | sort -u | grep -v -E '^(z |cd )' | fzf --border --ansi --height=40%)

if [[ -n $selected ]]; then
    echo -n "$selected" | wl-copy
    echo "'$selected' copied to clipboard."
fi
