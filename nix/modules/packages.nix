{ pkgs, ... }: {
  core = with pkgs; [
    bash
    blesh
    btop
    coreutils
    curl
    diffutils
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
    unzip
    util-linux
    vit
    wget
    zip
    zoxide
  ];

  dev = with pkgs; [
    awscli2
    cargo
    clang
    cmake
    jdk
    marksman
    maven
    nodejs
    pnpm
  ];

  desktop = with pkgs; [
    alacritty
    librewolf
    obsidian
    openconnect
    pavucontrol
    pulseaudio
    vlc
  ];
}
