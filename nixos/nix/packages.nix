{ pkgs, ... }: {
  dev = with pkgs; [
    ansible
    awscli2
    btop
    coreutils
    curl
    entr
    eza
    fzf
    gh
    git
    git-lfs
    git-secrets
    hurl
    hyperfine
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
    wget
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
    makeWrapper
    maven
    nodejs
    pkg-config
  ];

  desktop = with pkgs; [
    alacritty
    chromium
    cups
    dbus
    discord
    feh
    gimp
    icu
    lshw
    networkmanagerapplet
    obsidian
    pavucontrol
    protonvpn-gui
    pulseaudio
    scrot
    vlc
  ];
}
