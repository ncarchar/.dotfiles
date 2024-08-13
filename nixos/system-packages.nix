{ config, pkgs, ... }:
{
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w"
  ];
  environment.systemPackages = with pkgs; [
    acpi
    alacritty
    ansible
    autoconf
    autoconf
    automake
    automake
    bison
    dbus
    cargo
    clang_18
    cups
    cmake
    eza
    feh
    flex
    fontforge
    fzf
    gammastep
    gcc
    git
    gnome.gnome-keyring
    gnumake
    go
    grim
    home-manager
    i2c-tools
    jq
    libiconv
    libsecret
    libgcc
    libtool
    lshw
    makeWrapper
    mako
    maven
    jdk21_headless
    neofetch
    networkmanagerapplet
    nodePackages."@angular/cli"
    nodePackages."eslint"
    nodePackages."prettier"
    nodePackages."typescript"
    nodejs
    openrgb
    openvpn
    pavucontrol
    pciutils
    pkg-config
    pulseaudio
    python3
    ripgrep
    rustc
    scrot
    slurp
    spotify
    stow
    swaybg
    swayidle
    swaylock
    tmux
    unzip
    waybar
    wf-recorder
    wget
    wl-clipboard
    wofi
    xclip
    zig
    zip
    zoxide
  ];
}
