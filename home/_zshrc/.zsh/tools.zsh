source $HOME/.scripts/fzf-git.sh
eval "$(zoxide init zsh)"
source <(ng completion script)

run_pv() {
    zle -I
    pv
}

zle -N run_pv
bindkey "^I^I" run_pv
