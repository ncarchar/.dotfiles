{ pkgs, ... }: {
  dev = with pkgs; [
    awscli2
    btop
    cargo
    clang
    cmake
    coreutils
    curl
    entr
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
    neofetch
    nodejs
    parallel
    pnpm
    python3
    rename
    ripgrep
    sshfs
    starship
    stow
    tmux
    unzip
    util-linux
    wget
    xclip
    zip
    zoxide
  ];

  temp = with pkgs; [
  ];

  desktop = with pkgs; [
    alacritty
    chromium
    discord
    feh
    gimp
    networkmanagerapplet
    obsidian
    pavucontrol
    protonvpn-gui
    pulseaudio
    scrot
    vlc
  ];
}
