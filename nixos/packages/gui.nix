{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    alacritty
    chromium
    cups
    feh
    networkmanagerapplet
    obsidian
    pavucontrol
    protonvpn-gui
    spotify
  ];
}
