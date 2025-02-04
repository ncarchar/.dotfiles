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

for file in ~/.zsh/*.zsh; do
    filename=$(basename "$file")
    if [[ ! " ${IGNORE_FILES[@]} " =~ " ${filename} " ]]; then
        source "$file"
    fi
done

if [ -e /home/cvhew/.nix-profile/etc/profile.d/nix.sh ]; then . /home/cvhew/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer

if [[ -n "$IN_NIX_SHELL" ]]; then
    export PS1="(nix) $PS1"
fi
