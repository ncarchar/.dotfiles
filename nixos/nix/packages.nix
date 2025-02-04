{ pkgs, ... }:
{
  dev = with pkgs; [
    ansible
    bat
    busybox
    btop
    cups
    curl
    dbus
    eza
    fzf
    git
    gptfdisk
    jq
    lshw
    neofetch
    ntfs3g
    parted
    pciutils
    ripgrep
    stow
    tmux
    unzip
    usbutils
    wget
    xclip
    zip
    zoxide
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
    zig
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
