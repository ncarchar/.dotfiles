{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    alacritty
    chromium
    cups
    feh
    gimp
    insomnia
    networkmanagerapplet
    obsidian
    pulseaudio
    pavucontrol
    protonvpn-gui
    vlc
  ];
}
