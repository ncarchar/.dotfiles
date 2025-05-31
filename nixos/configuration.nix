{ pkgs, ... }:
let
  packages = import "/etc/nixos/nix/packages.nix" { pkgs = pkgs; };
in
{
  imports =
    [
      /etc/nixos/hardware-configuration.nix
      /etc/nixos/nix/vm.nix
    ];
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "24.11";
  programs.nix-ld.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;

  networking.hostName = "nixos";
  networking.nameservers = [ "1.0.0.1" "1.1.1.1" ];
  networking.networkmanager = {
    enable = true;
    settings = {
      connection = {
        "wifi.powersave" = 0;
      };
      device = {
        "wifi.scan-rand-mac-address" = false;
        "wifi.backend" = "wpa_supplicant";
      };
    };
  };

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";

  security.rtkit.enable = true;
  hardware.pulseaudio.enable = false;
  programs.noisetorch.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  environment.systemPackages = packages.dev ++ packages.core ++ packages.lang ++ packages.gui ++ packages.desktop;
  virtualisation.docker.enable = true;

  users.users.ncarchar = {
    isNormalUser = true;
    home = "/home/ncarchar";
    description = "Carson Miller";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "docker" ];
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  fonts.fontconfig = {
    defaultFonts = {
      serif = [ "Liberation Serif" "Vazirmatn" ];
      sansSerif = [ "Ubuntu" "Vazirmatn" ];
      monospace = [ "JetBrainsMono Nerd Font" ];
    };
  };
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.gdm.enableGnomeKeyring = true;
  security.pam.services.gdm-password.enableGnomeKeyring = true;

  # i3 + picom
  services.picom = {
    enable = true;
    settings = {
      backend = "glx";
      vsync = true;
    };
  };

  services.xserver = {
    enable = true;
    autorun = true;
    videoDrivers = [ "amdgpu" ];
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        i3status
        i3blocks
      ];
    };
  };


  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    ohMyZsh = {
      enable = true;
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
  programs.firefox.enable = true;
  programs.thunar.enable = true;
  programs.steam.enable = true;
  location = {
    provider = "manual";
    longitude = -80.0;
    latitude = 40.0;
  };
  services.redshift = {
    enable = true;
    temperature.night = 5000;
    temperature.day = 6500;
    brightness.night = "0.9";
    brightness.day = "1";
  };

  programs.git = {
    enable = true;
    config = {
      init = {
        defaultBranch = "main";
      };
      core = {
        pager = "less -F -X";
      };
    };
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.amdgpu.initrd.enable = true;
  hardware.amdgpu.opencl.enable = true;
  hardware.amdgpu.amdvlk.enable = true;
  hardware.graphics.extraPackages = with pkgs; [
    rocmPackages.clr
    rocmPackages.hip-common
    rocmPackages.rocm-runtime
    rocmPackages.rocm-device-libs
    rocmPackages.rocblas
    rocmPackages.rocm-smi
    amdvlk
  ];

  services.ollama = {
    enable = true;
    acceleration = "rocm";
    rocmOverrideGfx = "11.0.0";
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
