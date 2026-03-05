#!/usr/bin/env bash
set -u

git fetch -p

mapfile -t branches < <(git branch -vv | awk '/: gone]/{print $1}')

if [ ${#branches[@]} -eq 0 ]; then
    echo "No local branches to delete."
    exit 0
fi

echo "The following local branches will be deleted:"
printf '  %s\n' "${branches[@]}"

read -r -p "Proceed? [y/N] " answer

if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
    echo "Aborted."
    exit 0
fi

for b in "${branches[@]}"; do
    if git branch -d "$b"; then
        continue
    fi

    read -r -p "Branch '$b' is not fully merged. Force delete? [y/N] " force_answer

    if [[ "$force_answer" == "y" || "$force_answer" == "Y" ]]; then
        if git branch -D "$b"; then
            echo "Force deleted $b"
        else
            echo "Failed to force delete $b"
        fi
    else
        echo "Skipped $b"
    fi
done

echo "Done."
