#!/bin/bash

CODE_DIR="${CODE_DIR:-$HOME/code}"

find_git_with_origin() {
    local search_origin="$1"
    local found_dir=""

    if [ -z "$search_origin" ]; then
        return 1
    fi

    search_origin=$(echo "$search_origin" | tr -d '\n' | tr -d '\r' | awk '{$1=$1};1')

    while IFS= read -r dir; do
        if [ ! -d "$dir/.git" ]; then
            continue
        fi

        origin_url=$(git -C "$dir" remote get-url origin 2>/dev/null | tr -d '\n' | tr -d '\r' | sed 's/^[ \t]*//;s/[ \t]*$//')

        if [ "$origin_url" = "$search_origin" ]; then
            echo "$dir"
            return 0
        fi
    done < <(find "$CODE_DIR" -type d -mindepth 1 -maxdepth 3)

    return 1
}

selected=$(gh api user/repos --jq '.[] | [.name, .ssh_url] | @tsv' | column -t -s $'\t' | fzf --border --height 40%)

if [ -n "$selected" ]; then
    selected=$(echo $selected | tr -d '\n' | tr -d '\r')
    repo_name=$(echo "$selected" | cut -d' ' -f1 | awk '{$1=$1};1')
    ssh_url=$(echo "$selected" | cut -d' ' -f2- | awk '{$1=$1};1')

    ssh_url=$(echo "$ssh_url" | tr -d '\n' | tr -d '\r')

    echo "repo: '$repo_name' url: '$ssh_url'" >&2

    matching_repo=$(find_git_with_origin "$ssh_url")

    if [ -n "$matching_repo" ]; then
        echo "cd to $matching_repo" >&2
        cd "$matching_repo" || exit
    else
        clone_dir="$CODE_DIR/$repo_name"
        echo "No matching local repository found." >&2
        echo "Would you like to clone it to $clone_dir? (y/n)" >&2
        read -r answer
        if [ "$answer" = "y" ]; then
            mkdir -p "$(dirname "$clone_dir")"
            git clone "$ssh_url" "$clone_dir"
            cd "$clone_dir" || exit
        fi
    fi
fi
