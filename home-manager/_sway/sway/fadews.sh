#!/bin/sh

fade_effect() {
    local FPS=60
    local TIME_S=0.15

    local frames=$(dc -e "$FPS $TIME_S * 1/ p")
    local step_time=$(dc -e "3k 1 $FPS / p")
    local step_opacity=$(dc -e "3k $step_time $TIME_S / p")

    for i in $(seq $frames); do
        sleep $step_time
        for id in $container_ids; do
            swaymsg "[con_id=$id]" opacity plus $step_opacity
        done
    done
}

set_opacity_to_zero() {
    local workspace_id=$1
    local container_ids=$(swaymsg -t get_tree | jq -r --arg id "$workspace_id" '.nodes[].nodes[] | select(.id == ($id | tonumber)) | .nodes[].id')
    for id in $container_ids; do
        swaymsg "[con_id=$id]" opacity 0.10
    done
}

handle_workspace_event() {
    local event="$1"
    old_workspace_id=$(echo "$event" | jq -r '.old.id')
    new_workspace_id=$(echo "$event" | jq -r '.current.id')
    if [ "$old_workspace_id" != "null" ]; then
        set_opacity_to_zero "$old_workspace_id"
    fi
    container_ids=$(echo "$event" | jq -r '.current.nodes[].id')
    fade_effect
    for id in $container_ids; do
        swaymsg "[con_id=$id]" opacity 1
    done
}

check_and_start_sway() {
    if ! pgrep -x "sway" > /dev/null; then
        exit 1
    fi
}

while true; do
    check_and_start_sway

    swaymsg -t subscribe '["workspace"]' | while read -r event; do
        handle_workspace_event "$event"
    done

    sleep 0.05
done
