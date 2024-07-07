{ config, pkgs, ... }:
{
    home.packages = with pkgs; [
        ansible
        automake
        cargo
        cmake
        eza
        fzf
        gcc
        git
        go
        jq
        neovim
        nodePackages."@angular/cli"
        nodePackages."prettier"
        nodePackages."typescript"
        nodejs
        python312
        ripgrep
        tmux
        unzip
        xclip
        zig
        zip
        zoxide
      ];
}