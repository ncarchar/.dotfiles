{ pkgs, ... }:
{
  dev = with pkgs; [
    ansible
    btop
    coreutils
    curl
    eza
    fzf
    git
    git-lfs
    git-secrets
    gh
    hyperfine
    jq
    neofetch
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
    networkmanager
    wpa_supplicant
    cups
    dbus
    gptfdisk
    icu
    lshw
    ntfs3g
    parted
    pciutils
    rpi-imager
    scrot
    usbutils
  ];

  core = with pkgs; [
    autoconf
    automake
    bison
    clang
    cmake
    flex
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
