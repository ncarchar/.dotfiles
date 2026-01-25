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
    jdk
    maven
    nodejs
    pnpm
    python3
  ];

  desktop = with pkgs; [
    alacritty
    librewolf
    obsidian
    openconnect
    pavucontrol
    pulseaudio
    texliveFull
    vlc
    zathura
  ];
}
