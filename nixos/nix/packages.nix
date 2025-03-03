{ pkgs, ... }:
{
  dev = with pkgs; [
    ansible
    bat
    busybox
    btop
    curl
    eza
    fzf
    git
    hyperfine
    jq
    neofetch
    ripgrep
    starship
    stow
    tmux
    unzip
    wget
    xclip
    xmlstarlet
    zip
    zoxide
  ];

  desktop = with pkgs; [
    networkmanager
    wpa_supplicant
    cups
    dbus
    gptfdisk
    lshw
    ntfs3g
    parted
    pciutils
    rpi-imager
    usbutils
  ];

  core = with pkgs; [
    autoconf
    automake
    bison
    clang
    cmake
    flex
    gcc
    gcc11
    gnumake
    libstdcxx5
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
    nodejs
    (python3.withPackages (ps: with ps; [
      pip
    ]))
  ];

  gui = with pkgs; [
    alacritty
    bambu-studio
    chromium
    cups
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
