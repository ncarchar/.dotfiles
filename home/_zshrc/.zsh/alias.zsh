alias hist=". hist"
alias tms="tms"
alias bash="zsh"
alias cp="cp -a"

command -v exa >/dev/null 2>&1 && {
    alias ls="exa --all --across --group-directories-first"
    alias la="exa --all --across --group-directories-first"
    alias ll="exa -l --all -g --icons --git --no-user --classify --group-directories-first"
    alias lt="exa --level=1 --icons --tree --git --git-ignore --no-user --no-permissions --group-directories-first -a"
    alias llt="exa --level=2 --icons --tree --git --git-ignore --no-user --no-permissions --group-directories-first -a"
    alias lft="exa --icons --tree --git --git-ignore --no-user --no-permissions --group-directories-first -a"
}
