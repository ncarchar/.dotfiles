#!/usr/bin/env sh

pkill -f ~/.config/sway/fadews.sh

while pgrep -f ~/.config/sway/fadews.sh >/dev/null; do
  sleep 1
done

exec ~/.config/sway/fadews.sh
