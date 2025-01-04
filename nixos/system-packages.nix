{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # GUI Apps
    alacritty
    chromium
    cups
    feh
    networkmanagerapplet
    obsidian
    pavucontrol
    protonvpn-gui
    spotify

    # C++/Make Apps
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

    # Core Programs/Development Tools
    ansible
    cups
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
    wget
    xclip
    zip
    zoxide

    # Languages (Rust, Go, Node, etc.)
    cargo
    go
    jdk21
    maven
    nodePackages."@angular/cli"
    nodePackages."eslint"
    nodePackages."http-server"
    nodePackages."prettier"
    nodePackages."typescript"
    nodejs
    rustc
    zig
    (python3.withPackages (ps: with ps; [
      i3ipc
    ]))
  ];
}
