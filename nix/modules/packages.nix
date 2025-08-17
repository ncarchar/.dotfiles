{ pkgs, ... }: {
  dev = with pkgs; [
    awscli2
    bash
    blesh
    btop
    cargo
    clang
    cmake
    coreutils
    curl
    eza
    fzf
    gh
    git
    git-lfs
    gnugrep
    gnumake
    hurl
    jdk
    jq
    maven
    nodejs
    parallel
    pnpm
    python3
    ripgrep
    starship
    stow
    tmux
    unzip
    util-linux
    wget
    zip
    zoxide
  ];

  desktop = with pkgs; [
    alacritty
    librewolf
    newsboat
    obsidian
    pavucontrol
    protonvpn-gui
    pulseaudio
    vlc
  ];
}
