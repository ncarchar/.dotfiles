#!/bin/sh

export PATH="$HOME/.scripts:$PATH"

source ~/.shell/alias.sh
eval "$(starship init bash)"
