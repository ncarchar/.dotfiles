export PATH="$HOME/.scripts:$PATH"
export HOSTNAME=$(hostname)
HOSTNAME=$HOSTNAME

autoload -U compinit promptinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
fpath=(/usr/local/share/zsh-completions $fpath)

IGNORE_FILES=()

if [[ ! "$HOSTNAME" == COV* ]]; then
    IGNORE_FILES=("_cov.zsh")
fi

for file in ~/.shell/*; do
    filename=$(basename "$file")
    if [[ ! " ${IGNORE_FILES[@]} " =~ " ${filename} " ]]; then
        source "$file"
    fi
done



if [[ -n "$IN_NIX_SHELL" ]]; then
    export PS1="(nix) $PS1"
fi

source $HOME/.scripts/fzf-git.sh
eval "$(zoxide init zsh)"
source <(ng completion script)
bindkey '^E' end-of-line
eval "$(starship init zsh)"
