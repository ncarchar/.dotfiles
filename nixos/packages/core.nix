{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    ansible
    btop
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
  ];
}
