export HOSTNAME=$(hostname)
HOSTNAME=$HOSTNAME

zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path ~/.zsh_cache

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
