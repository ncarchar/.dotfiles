#!/usr/bin/env bash
set -euo pipefail

HISTFILE="${HISTFILE:-$HOME/.bash_history}"

history -a
history -n

start=$(date -d "today 00:00" +%s)

first_ts=""

while IFS= read -r line; do
    if [[ $line == \#* ]]; then
        ts=${line#\#}
        [[ $ts =~ ^[0-9]+$ ]] || continue
        if ((ts < start)); then
            break
        fi
        first_ts=$ts
    fi
done < <(tac "$HISTFILE")

if [[ -n ${first_ts} ]]; then
    now=$(date +%s)
    elapsed=$((now - first_ts))
    hours=$((elapsed / 3600))
    mins=$(((elapsed % 3600) / 60))
    echo "$(date -d "@$first_ts") (${hours} hours, ${mins} minutes)"
else
    echo "No data found for today."
fi
