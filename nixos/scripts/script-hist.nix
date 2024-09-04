{ pkgs }:
pkgs.writeShellApplication {
  name = "hist";
  runtimeInputs = [ pkgs.zsh pkgs.fzf pkgs.gnused pkgs.gawk pkgs.wl-clipboard ];
  text = ''
    #!/usr/bin/env zsh
    set -e
    set -o pipefail

    HISTFILE="$HOME/.zsh_history"
    if [[ ! -f "$HISTFILE" ]]; then
      echo "History file not found: $HISTFILE"
      exit 1
    fi

    echo "Debug: Starting history selection process"
    
    history_content=$(tac "$HISTFILE" | sed 's/^: [0-9]*:[0-9];//' || echo "Failed to process history file")
    echo "Debug: History content processed"

    selected=$(echo "$history_content" | fzf --border --ansi --height 40% || echo "FZF selection failed")
    echo "Debug: FZF selection complete"

    if [[ -n $selected ]]; then
        cleaned_selection=$(echo "$selected" | sed 's/[^ ]* [^ ]* //' | awk '{$1=$1};1' || echo "Failed to clean selection")
        echo "Debug: Selection cleaned"

        if echo -n "$cleaned_selection" | wl-copy; then
            echo "'$cleaned_selection' copied to clipboard."
        else
            echo "Failed to copy to clipboard"
        fi
    else
        echo "No selection made"
    fi

    echo "Debug: Script completed successfully"
  '';
}
