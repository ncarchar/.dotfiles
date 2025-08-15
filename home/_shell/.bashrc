#!/bin/sh

export PATH="$HOME/.scripts:$PATH"

source "$(dirname "$(dirname "$(realpath "$(which blesh-share)")")")/share/blesh/ble.sh"

source ~/.shell/alias.sh
source ~/.shell/fzf.sh
source ~/.shell/bleconf.sh

bind 'set show-all-if-ambiguous on'

eval "$(starship init bash)"
eval "$(zoxide init bash)"

if [[ $HOSTNAME == COV* ]]; then
    export BROWSER="/mnt/c/Program Files/Mozilla Firefox/firefox.exe"
fi

if [[ -z "$TMUX" ]]; then
    tmux
fi
