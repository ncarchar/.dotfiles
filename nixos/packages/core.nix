{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    ansible
    busybox
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
    nvtop
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
}
