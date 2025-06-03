{ pkgs, ... }: {
  dev = with pkgs; [
    awscli2
    btop
    busybox
    coreutils
    curl
    entr
    eza
    fzf
    gh
    git
    git-lfs
    hurl
    jq
    neofetch
    rename
    ripgrep
    sshfs
    starship
    stow
    tmux
    util-linux
    xclip
    zip
    zoxide
  ];

  core = with pkgs; [
    angular-language-server
    cargo
    clang
    cmake
    jdk
    maven
    nodejs
    nodePackages."@angular/cli"
    nodePackages."typescript"
  ];

  desktop = with pkgs; [
    alacritty
    chromium
    discord
    feh
    gimp
    networkmanagerapplet
    obsidian
    pavucontrol
    protonvpn-gui
    pulseaudio
    scrot
    vlc
  ];
}
