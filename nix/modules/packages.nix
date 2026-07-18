{ pkgs, ... }:
{
  core = with pkgs; [
    atuin
    bash
    blesh
    btop
    coreutils
    curl
    diffutils
    direnv
    eza
    fastfetch
    file
    findutils
    fzf
    gh
    git
    gnugrep
    gnumake
    jq
    just
    parallel
    ripgrep
    starship
    stow
    tmux
    tree-sitter
    unzip
    util-linux
    wget
    zip
    zoxide
  ];

  dev = with pkgs; [
    awscli2
    cargo
    clang
    cmake
    javaPackages.compiler.openjdk25
    (maven.override { jdk_headless = javaPackages.compiler.openjdk25; })
    nodejs
    pnpm
    python3
  ];

  desktop = with pkgs; [
    alacritty
    bambu-studio
    discord
    librewolf
    obsidian
    pavucontrol
    proton-vpn
    pulseaudio
    spotify
    vlc
  ];
}
