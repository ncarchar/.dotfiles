export PATH="$HOME/.scripts:$PATH"
export HOSTNAME=$(hostname)
HOSTNAME=$HOSTNAME

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

source $HOME/.scripts/fzf-git.sh
source <(ng completion script)
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
