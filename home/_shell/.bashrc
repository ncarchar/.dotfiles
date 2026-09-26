#!/bin/sh

# Only run for interactive shells
[[ $- == *i* ]] || return

export PATH="$HOME/.scripts:$PATH"
export PATH="/home/cvhew/.local/bin:$PATH"

source ~/.shell/alias.sh
source ~/.shell/fzfconf.sh

if [[ "$(uname -s)" != "Darwin" ]]; then
    source ~/.shell/bleconf.sh
fi

bind 'set show-all-if-ambiguous on'

# disable shell exit on Ctrl+d
export IGNOREEOF=999

# history
shopt -s histappend
HISTFILESIZE=5000
HISTCONTROL=ignorespace:ignoredups
HISTTIMEFORMAT="%F %T "

# Scale QT & GDK Apps
export QT_SCALE_FACTOR=1.4
export GDK_SCALE=1.0
export GDK_DPI_SCALE=1.4

# direnv
eval "$(direnv hook bash)"

# prompt
eval "$(starship init bash)"

# manually alias zoxide
export _ZO_ECHO=1
eval "$(zoxide init bash --no-cmd)"
alias z="__zoxide_z"

# atuin history
eval "$(atuin init bash --disable-up-arrow)"

if [[ $HOSTNAME == COV* ]]; then
    alias ps-copy="/mnt/c/WINDOWS/system32/clip.exe"
    export BROWSER="/mnt/c/Users/CVHEW/AppData/Local/Mozilla Firefox/firefox.exe"
    export JAVA_TOOL_OPTIONS="-Djavax.net.ssl.trustStore=$HOME/.certs-java/ca-trust.p12 -Djavax.net.ssl.trustStorePassword=changeit"
    export COV=1
    export wstore=/mnt/c/Store
    export whome=/mnt/c/Users/CVHEW
fi
