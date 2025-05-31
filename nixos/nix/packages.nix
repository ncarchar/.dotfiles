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
    git
    git-lfs
    git-secrets
    gh
    hyperfine
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
    wget
    xclip
    zip
    zoxide
  ];

  desktop = with pkgs; [
    cups
    dbus
    gptfdisk
    icu
    lshw
    networkmanager
    ntfs3g
    parted
    pciutils
    rpi-imager
    scrot
    usbutils
    wpa_supplicant
  ];

  core = with pkgs; [
    autoconf
    automake
    bison
    clang
    cmake
    flex
    gnumake
    libtool
    makeWrapper
    pkg-config
  ];

  lang = with pkgs; [
    cargo
    jdk
    maven
    # nodePackages."@angular/cli"
    # nodePackages."eslint"
    # nodePackages."prettier"
    # nodePackages."typescript"
    nodejs
  ];

  gui = with pkgs; [
    alacritty
    chromium
    cups
    discord
    feh
    gimp
    networkmanagerapplet
    obsidian
    pulseaudio
    pavucontrol
    protonvpn-gui
    vlc
  ];
}
