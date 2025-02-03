HOSTNAME=$HOSTNAME

if [[ ! "$HOSTNAME" == COV* ]]; then
    IGNORE_FILES=("_cov.zsh")
fi

for file in ~/.zsh/*.zsh; do
    filename=$(basename "$file")
    if [[ ! " ${IGNORE_FILES[@]} " =~ " ${filename} " ]]; then
        source "$file"
    fi
done
