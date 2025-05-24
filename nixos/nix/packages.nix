{ pkgs, ... }: {
  dev = with pkgs; [
    ansible
    awscli2
    btop
    # busybox
    coreutils
    curl
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
    tmux-mem-cpu-load
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
    libstdcxx5
    lshw
    networkmanager
    noisetorch
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
    nodePackages."@angular/cli"
    nodePackages."eslint"
    nodePackages."prettier"
    nodePackages."typescript"
    nodePackages."aws-cdk"
    nodePackages."serve"
    nodejs
  ];

  gui = with pkgs; [
    alacritty
    bambu-studio
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
