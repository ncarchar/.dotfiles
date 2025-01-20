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
    xsane
    spotify
    vlc
  ];
}
