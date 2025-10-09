alias tms="tms.sh"
alias started="source started.sh"
alias cp="cp -a"
alias git-search="source ~/.scripts/git-search.sh"
alias nvim-min="nvim -u ~/.config/nvim/init-min.lua"
alias _npm="$(command -v npm)"
alias npm="pnpm"

if command -v exa >/dev/null 2>&1; then
    alias ls="eza --all --group-directories-first -F --icons=always --width 80"
    alias ll="eza --all --group-directories-first -F --git -l"
    alias lldu="eza --all --group-directories-first -F --git -l --total-size"
    alias lt="eza --level=1 --icons --tree --git --git-ignore --no-user --no-permissions --group-directories-first -a"
    alias llt="eza --level=2 --icons --tree --git --git-ignore --no-user --no-permissions --group-directories-first -a"
    alias lft="eza --icons --tree --git --git-ignore --no-user --no-permissions --group-directories-first -a"
fi
