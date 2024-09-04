{ pkgs }:

pkgs.writeShellApplication {
  name = "hist-nix";
  runtimeInputs = [ pkgs.zsh pkgs.fzf pkgs.gnused pkgs.gawk pkgs.wl-clipboard ];
  text = ''
    #!/usr/bin/env zsh

    selected=$(fc -ln -t '%F %T' | fzf --border --ansi --height 40% | sed 's/[^ ]* [^ ]* //' | awk '{$1=$1};1')

    if [[ -n $selected ]]; then
        echo -n "$selected" | wl-copy
        echo "'$selected' copied to clipboard."
    fi
  '';
}
