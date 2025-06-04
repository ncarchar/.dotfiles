{ pkgs, ... }: {
  dev = with pkgs; [
    awscli2
    btop
    coreutils
    curl
    entr
    eza
    fzf
    gnugrep
    gh
    git
    git-lfs
    hurl
    jq
    neofetch
    rename
    ripgrep
    sshfs
    starship
    stow
    tmux
    unzip
    util-linux
    xclip
    zip
    zoxide
  ];

  core = with pkgs; [
    cargo
    clang
    cmake
    gnumake
    jdk
    maven
    nodejs
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
