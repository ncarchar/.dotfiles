{ pkgs, ... }:
{
  core = with pkgs; [
    atuin
    bash
    bc
    blesh
    btop
    bubblewrap
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
    herdr
    jq
    just
    parallel
    pi-coding-agent
    ripgrep
    socat
    starship
    stow
    tmux
    tree-sitter
    unzip
    util-linux
    uv
    wget
    whisper-cpp
    zip
    zoxide
  ];

  dev = with pkgs; [
    awscli2
    cargo
    clang
    cmake
    gradle
    javaPackages.compiler.openjdk25
    (maven.override { jdk_headless = javaPackages.compiler.openjdk25; })
    nodejs
    pnpm
    postgresql
    python3
    typescript
    typescript-language-server
    angular-language-server
    jdt-language-server
  ];

  desktop = with pkgs; [
    alacritty
    bambu-studio
    chromium
    discord
    faugus-launcher
    librewolf
    obsidian
    pavucontrol
    proton-vpn
    pulseaudio
    spotify
    vlc
  ];
}
