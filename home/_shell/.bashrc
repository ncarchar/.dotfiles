#!/bin/sh

export PATH="$HOME/.scripts:$PATH"

source ~/.shell/alias.sh
source ~/.shell/fzf.sh
source ~/.shell/bleconf.sh

bind 'set show-all-if-ambiguous on'

eval "$(starship init bash)"
eval "$(zoxide init bash)"

if [[ -z "$TMUX" ]]; then
    tmux
fi
