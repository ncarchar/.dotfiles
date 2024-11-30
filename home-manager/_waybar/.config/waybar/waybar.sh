#!/usr/bin/env sh

pkill waybar

while pgrep -x waybar >/dev/null; do
  sleep 1
done

waybar
