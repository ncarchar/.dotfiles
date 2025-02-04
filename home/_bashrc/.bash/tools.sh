source "$HOME/.scripts/fzf-git.sh"

eval "$(zoxide init bash)"

source <(ng completion script)

run_pv() {
    pv
}

# bind -x '"\t\t": run_pv'
