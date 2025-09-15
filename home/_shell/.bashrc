#!/bin/sh

export PATH="$HOME/.scripts:$PATH"

source ~/.shell/alias.sh
source ~/.shell/bleconf.sh
source ~/.shell/fzfconf.sh

bind 'set show-all-if-ambiguous on'

# disable shell exit on Ctrl+d
export IGNOREEOF=999

# hist
shopt -s histappend
HISTFILESIZE=10000
HISTCONTROL=ignoredups:ignorespace
HISTTIMEFORMAT="%F %T "

# Scale QT Apps (VLC)
export QT_SCALE_FACTOR=1.5

# prompt
eval "$(starship init bash)"

# manually alias zoxide
export _ZO_ECHO=1
eval "$(zoxide init bash --no-cmd)"
alias z="__zoxide_z"

if [[ $HOSTNAME == COV* ]]; then
    alias vault="cd /mnt/c/Vaults && nvim ."
    export BROWSER="/mnt/c/Users/CVHEW/AppData/Local/Mozilla Firefox/firefox.exe"
    export JAVA_TOOL_OPTIONS="-Djavax.net.ssl.trustStore=$HOME/.certs-java/ca-trust.p12 -Djavax.net.ssl.trustStorePassword=changeit"
fi
