{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    spring-boot-cli
    openrgb-with-all-plugins
    bitwarden-cli
    openconnect
    hyprpaper
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
    home-manager
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
    jdk21_headless
    neofetch
    networkmanagerapplet
    nodePackages."@angular/cli"
    nodePackages."eslint"
    nodePackages."prettier"
    nodePackages."typescript"
    nodejs
    obsidian
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
