export PATH="$HOME/.scripts:$PATH"
export HOSTNAME=$(hostname)
export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true

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

bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line

eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

if [[ -z "$TMUX" ]]; then
    tmux
fi
