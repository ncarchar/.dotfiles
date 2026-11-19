#!/usr/bin/env bash
# Pick a pi window from any tmux session and jump to it. Needs-you first.
# State comes from the @pi_state window option set by the tmux-notify extension.

row=$(tmux list-windows -a -F '#{@pi_state}	#{session_name}	#{window_id}	#{window_name}' |
    awk -F'\t' '$1 != ""' | sort |
    fzf --delimiter='\t' --with-nth=1,2,4 --no-sort --prompt='pi> ') || exit 0

IFS=$'\t' read -r _ session window _ <<<"$row"
tmux select-window -t "$window" && tmux switch-client -t "$session"
