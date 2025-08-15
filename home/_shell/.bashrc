#!/bin/sh

shopt -s histappend

bind 'set show-all-if-ambiguous on'

# Disable exit on Ctrl+d
export IGNOREEOF=999

HISTFILESIZE=10000
HISTCONTROL=ignoredups:ignorespace
HISTTIMEFORMAT="%F %T "

export PATH="$HOME/.scripts:$PATH"

source ~/.shell/alias.sh
source ~/.shell/fzf.sh
source ~/.shell/bleconf.sh

eval "$(starship init bash)"
eval "$(zoxide init bash)"

if [[ $HOSTNAME == COV* ]]; then
    export BROWSER="/mnt/c/Program Files/Mozilla Firefox/firefox.exe"
fi

if [[ -z "$TMUX" ]]; then
    tmux
fi
