{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    btop
    xorg.xhost
    xwayland
    parted
    gptfdisk
    ntfs3g
    inotify-tools
    plantuml
    gavin-bc
    spring-boot-cli
    bitwarden-cli
    openconnect
    gammastep
    lm_sensors
    acpi
    alacritty
    ansible
    autoconf
    automake
    bison
    dbus
    cargo
    chromium
    clang
    cups
    cmake
    eza
    feh
    flex
    fontforge
    fzf
    gammastep
    gcc
    gcc11
    git
    gnumake
    go
    grim
    i2c-tools
    jq
    libiconv
    libstdcxx5
    libsecret
    libgcc
    libtool
    lshw
    makeWrapper
    mako
    maven
    jdk21
    neofetch
    networkmanagerapplet
    nodePackages."@angular/cli"
    nodePackages."eslint"
    nodePackages."prettier"
    nodePackages."typescript"
    nodePackages."http-server"
    nodejs
    obsidian
    openvpn
    pavucontrol
    pciutils
    pkg-config
    pulseaudio
    (python3.withPackages (ps: with ps; [
      i3ipc
    ]))
    ripgrep
    rustc
    slurp
    spotify
    stow
    tmux
    unzip
    waybar
    wf-recorder
    wget
    wl-clipboard
    xclip
    zig
    zip
    zoxide
  ];
}
