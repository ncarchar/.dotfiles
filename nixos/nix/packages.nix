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
    cups
    dbus
    gptfdisk
    lshw
    ntfs3g
    parted
    piper
    pciutils
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
    jdk21
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
