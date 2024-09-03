# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
{
  imports =
    [
      /etc/nixos/hardware-configuration.nix
      /etc/nixos/system-packages.nix
      /etc/nixos/vm.nix
      /etc/nixos/zsh.nix
    ];
  nixpkgs.config = {
    packageOverrides = pkgs: {
      unstable = import <nixos-unstable> {
        config = config.nixpkgs.config;
      };
    };
  };
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  programs.nix-ld.enable = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.useOSProber = true;
  networking.hostName = "nixos";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # docker
  virtualisation.docker.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ncarchar = {
    isNormalUser = true;
    description = "Carson Miller";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "docker" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  fonts.fontconfig = {
    defaultFonts = {
      serif = [ "Liberation Serif" "Vazirmatn" ];
      sansSerif = [ "Ubuntu" "Vazirmatn" ];
      monospace = [ "JetBrainsMono" ];
    };
  };

  # This value determines the NixOS release from which the default
  system.stateVersion = "24.05";

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.gdm.enableGnomeKeyring = true; # load gnome-keyrin
  security.pam.services.gdm-password.enableGnomeKeyring = true;

  # programs.hyprland = {
  #   enable = true;
  #   xwayland.enable = true;
  # };

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  services = {
    displayManager = {
      sddm.enable = true;
      sddm.wayland.enable = true;
      sddm.theme = "where_is_my_sddm_theme";
    };
  };

  hardware.opengl.enable = true;

  systemd.extraConfig = ''
    DefaultTimeoutStopSec=10s
  '';

  programs.seahorse.enable = true;
  programs.dconf.enable = true;
  programs.neovim.enable = true;
  environment.variables.EDITOR = "nvim";
  programs.firefox.enable = true;
  programs.thunar.enable = true;

  programs.git = {
    enable = true;
    config = {
      init = {
        defaultBranch = "main";
      };
      user = {
        email = "carsoncmiller@proton.me";
        name = "ncarchar";
      };
      core = {
        pager = "less -F -X";
      };
    };
  };

  programs.steam = {
    enable = true;
  };

  programs.gamemode.enable = true;

  # automatic updates and removal of old builds
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # config for printer
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
