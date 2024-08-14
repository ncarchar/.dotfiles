# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
{
  imports =
    [
      /etc/nixos/hardware-configuration.nix
      /etc/nixos/system-packages.nix
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

  boot.loader = {
    timeout = 3;
    efi = {
      canTouchEfiVariables = true;
    };
    grub = {
      gfxmodeEfi = "1920x1440,1280x1024,1024x768,auto";
      enable = true;
      efiSupport = true;
      device = "nodev";
      useOSProber = true;
    };
  };

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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ncarchar = {
    isNormalUser = true;
    description = "Carson Miller";
    extraGroups = [ "networkmanager" "wheel" ];
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


  services = {
    xserver = {
      xkb.layout = "us";
      enable = true;
      exportConfiguration = true;
      videoDrivers = [ "nvidia" ];
      screenSection = ''
        Option "metamodes" "DP-2: 5120x2160+0+0"
      '';
      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          i3status
          i3blocks
          i3lock
          dmenu
        ];
      };
      desktopManager = {
        xterm.enable = false;
        wallpaper.mode = "fill";
      };
    };
    displayManager = {
      defaultSession = "none+i3";
    };
    picom = {
      enable = true;
    };
  };

  hardware.opengl.enable = true;

  # Setup NVIDIA drivers
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };


  systemd.extraConfig = ''
    DefaultTimeoutStopSec=10s
  '';

  programs.seahorse.enable = true;
  programs.dconf.enable = true;
  programs.neovim.enable = true;
  programs.firefox.enable = true;
  programs.thunar.enable = true;



  programs.steam = {
    enable = true;
    package = with pkgs; steam.override {
      extraPkgs = pkgs:
        [ pkgs.openssl_1_1 ];
    };
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

  services.redshift = {
    enable = true;
    provider = "manual";
    latitude = "40.4406";
    longitude = "-79.9959";
    temperature = {
      day = 6500;
      night = 3750;
    };
    brightness = {
      day = "1.0";
      night = "0.85";
    };
  };

  location = {
    provider = "manual";
    latitude = 40.4406;
    longitude = -79.9959;
  };

  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    promptInit = "export PATH=$HOME/.scripts:$PATH\neval \"$(zoxide init zsh)\"";
    ohMyZsh = {
      theme = "robbyrussell";
      enable = true;
      plugins = [ "git" ];
    };
    shellAliases = {
      ls = "exa --across --group-directories-first";
      la = "exa --all --across  --group-directories-first";
      ll = "exa -l --all -g --icons --git --no-user --classify --group-directories-first";
      lt = "exa --level=1 --icons --tree --git --git-ignore --no-user --no-permissions --group-directories-first -a";
      lft = "exa --icons --tree --git --git-ignore --no-user --no-permissions --group-directories-first -a";
      hist = ". hist";
      tms = ". tms";
    };
  };
}
