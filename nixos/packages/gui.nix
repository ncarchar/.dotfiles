{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    alacritty
    chromium
    cups
    feh
    networkmanagerapplet
    obsidian
    pulseaudio
    pavucontrol
    protonvpn-gui
    simple-scan
    brscan5
    spotify
    vlc
  ];
}
