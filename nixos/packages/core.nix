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

    rocmPackages.clr
    rocmPackages.rpp
    rocmPackages.hipblas
    rocmPackages.rocblas
    rocmPackages.rocm-smi
    amdvlk
  ];
}
