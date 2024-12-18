{ config, pkgs, ... }:
{
  imports =
    [
      /etc/nixos/hardware-configuration.nix
      /etc/nixos/system-packages.nix
      /etc/nixos/vm.nix
      /etc/nixos/zsh.nix
    ];
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "24.11";
  programs.nix-ld.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  hardware.graphics.enable = true;

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";

  security.rtkit.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  virtualisation.docker.enable = true;

  users.users.ncarchar = {
    isNormalUser = true;
    home = "/home/ncarchar";
    description = "Carson Miller";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "docker" ];
  };

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


  services.gnome.gnome-keyring.enable = true;
  security.pam.services.gdm.enableGnomeKeyring = true;
  security.pam.services.gdm-password.enableGnomeKeyring = true;

  services.displayManager.defaultSession = "none+i3";
  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
    };
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        i3status
        i3blocks
      ];
    };
  };

  # programs.waybar.enable = true;
  # programs.sway = {
  #   enable = true;
  #   wrapperFeatures.gtk = true;
  #   xwayland.enable = true;
  # };

  programs.neovim.enable = true;
  environment.variables.EDITOR = "nvim";
  programs.firefox.enable = true;
  programs.thunar.enable = true;
  programs.steam.enable = true;

  programs.git = {
    enable = true;
    config = {
      init = {
        defaultBranch = "main";
      };
      core = {
        pager = "less -F -X";
      };
      "includeIf \"gitdir:/home/ncarchar/gatech/**\"" = {
        path = "/home/ncarchar/gatech/.gitconfig";
      };
    };
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
