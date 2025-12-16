#!/bin/sh

# Only run for interactive shells
[[ $- == *i* ]] || return

export PATH="$HOME/.scripts:$PATH"

source ~/.shell/alias.sh
source ~/.shell/bleconf.sh
source ~/.shell/fzfconf.sh

bind 'set show-all-if-ambiguous on'

# disable shell exit on Ctrl+d
export IGNOREEOF=999

# hist
shopt -s histappend
HISTFILESIZE=5000
HISTCONTROL=ignorespace
HISTTIMEFORMAT="%F %T "

# Scale QT & GDK Apps
export QT_SCALE_FACTOR=1.4
export GDK_SCALE=1.0
export GDK_DPI_SCALE=1.4

# prompt
eval "$(starship init bash)"

# manually alias zoxide
export _ZO_ECHO=1
eval "$(zoxide init bash --no-cmd)"
alias z="__zoxide_z"

if [[ $HOSTNAME == COV* ]]; then
    alias ps-copy="/mnt/c/WINDOWS/system32/clip.exe"
    export BROWSER="/mnt/c/Users/CVHEW/AppData/Local/Mozilla Firefox/firefox.exe"
    export JAVA_TOOL_OPTIONS="-Djavax.net.ssl.trustStore=$HOME/.certs-java/ca-trust.p12 -Djavax.net.ssl.trustStorePassword=changeit"
else
    gtvpn() {
        sudo -v || return 1
        read -s -p "cmiller427 password: " pw
        echo
        printf '%s\n%s\n%s\n' "$pw" "push1" "DC Gateway" | sudo openconnect \
            --protocol=gp vpn.gatech.edu \
            -u cmiller427 \
            --passwd-on-stdin
    }
fi
