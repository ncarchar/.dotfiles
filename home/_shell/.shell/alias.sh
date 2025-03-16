alias hist=". hist.sh"
alias tms="tms.sh"
alias bash="zsh.sh"
alias started="started.sh"
alias cp="cp -a"
alias git-search="source ~/.scripts/git-search.sh"
alias nvim-min="nvim -u ~/.config/nvim/init-min.lua"

if command -v exa >/dev/null 2>&1; then
    alias ls="exa --all --group-directories-first -F"
    alias ll="exa -l --all -g --git --no-user --classify --group-directories-first"
    alias lt="exa --level=1 --icons --tree --git --git-ignore --no-user --no-permissions --group-directories-first -a"
    alias llt="exa --level=2 --icons --tree --git --git-ignore --no-user --no-permissions --group-directories-first -a"
    alias lft="exa --icons --tree --git --git-ignore --no-user --no-permissions --group-directories-first -a --color=always"
fi
