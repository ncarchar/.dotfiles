#!/bin/sh

today_start=$(date -d "00:00:00" +%s)
today_end=$(date -d "23:59:59" +%s)
histfile="${ZSH_HISTFILE:-$HOME/.zsh_history}"
min_ts=""
min_cmd=""

while IFS= read -r line; do
    case "$line" in
    ": "*)
        entry=${line#: }
        ts=${entry%%:*}

        if ! [ "$ts" -eq "$ts" ] 2>/dev/null; then
            continue
        fi

        if [ "$ts" -ge "$today_start" ] && [ "$ts" -le "$today_end" ]; then
            if [ -z "$min_ts" ] || [ "$ts" -lt "$min_ts" ]; then
                min_ts=$ts
                min_cmd=${entry#*;}
            fi
        fi
        ;;
    esac
done <"$histfile"

if [ -n "$min_ts" ]; then
    now=$(date +%s)
    ELAPSED=$((now - min_ts))

    HOURS=$(((ELAPSED % 86400) / 3600))
    MINUTES=$(((ELAPSED % 3600) / 60))

    echo "$(date -d "@$min_ts") ($HOURS hours, $MINUTES minutes)"
else
    echo "No data found for today."
fi
