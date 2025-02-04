#!/bin/sh

export PATH="$HOME/.scripts:$PATH"

export HOSTNAME=$(hostname)
HOSTNAME=$HOSTNAME

IGNORE_FILES=()

if [[ ! "$HOSTNAME" =~ ^COV ]]; then
    IGNORE_FILES=("_cov.sh")
fi

for file in ~/.bash/*.sh; do
    filename=$(basename "$file")

    skip=false
    for ignore in "${IGNORE_FILES[@]}"; do
        if [[ "$filename" == "$ignore" ]]; then
            skip=true
            break
        fi
    done

    if [[ "$skip" == false ]]; then
        source "$file"
    fi
done
