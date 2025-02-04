#!/bin/sh
alias hist=". hist.sh"
alias tms="tms.sh"
alias started="started.sh"
alias cp="cp -a"

# Check if 'exa' is available and set aliases
if command -v exa >/dev/null 2>&1; then
    alias ls="exa --all --group-directories-first -F"
    alias ll="exa -l --all -g --icons --git --no-user --classify --group-directories-first"
    alias lt="exa --level=1 --icons --tree --git --git-ignore --no-user --no-permissions --group-directories-first -a"
    alias llt="exa --level=2 --icons --tree --git --git-ignore --no-user --no-permissions --group-directories-first -a"
    alias lft="exa --icons --tree --git --git-ignore --no-user --no-permissions --group-directories-first -a --color=always | less -R"
fi

# Check if 'bat' is available and set alias
if command -v bat >/dev/null 2>&1; then
    alias cat="bat"
    export BAT_THEME=base16
fi
