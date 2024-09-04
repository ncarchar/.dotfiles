{ pkgs }:
pkgs.writeShellApplication {
  name = "hist";
  runtimeInputs = [ pkgs.zsh pkgs.fzf pkgs.gnused pkgs.gawk pkgs.wl-clipboard ];
  text = ''
    #!/usr/bin/env zsh
    HISTFILE="$HOME/.zsh_history"
    if [[ ! -f "$HISTFILE" ]]; then
      echo "History file not found: $HISTFILE"
      exit 1
    fi

    selected=$(tac "$HISTFILE" | sed 's/^: [0-9]*:[0-9];//' | fzf --border --ansi --height 40% | sed 's/[^ ]* [^ ]* //' | awk '{$1=$1};1')
    if [[ -n $selected ]]; then
        echo -n "$selected" | wl-copy
        echo "'$selected' copied to clipboard."
    fi
  '';
}
