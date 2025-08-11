export PATH="$HOME/.scripts:$PATH"
export HOSTNAME=$(hostname)
export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true

HOSTNAME=$HOSTNAME

IGNORE_FILES=()

source ~/.shell/_cov.sh
source ~/.shell/alias.sh
source ~/.shell/fzf.sh

bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line

eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

if [[ -z "$TMUX" ]]; then
    tmux
fi
