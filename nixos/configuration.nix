{ config, pkgs, ... }:
{
  imports =
    [
      /etc/nixos/hardware-configuration.nix
      /etc/nixos/vm.nix
      /etc/nixos/packages/cpp.nix
      /etc/nixos/packages/core.nix
      /etc/nixos/packages/lang.nix
      /etc/nixos/packages/gui.nix
    ];
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "24.11";
  programs.nix-ld.enable = true;

  hardware.amdgpu.initrd.enable = true;
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
  services.saned = {
    enable = true;
    extraConfig = ''
      usb 0x04f9 0x0468
    '';
  };
  hardware.sane = {
    enable = true;
    brscan5.enable = true;
    dsseries.enable = true;
  };

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

  # i3 + picom
  services.displayManager.defaultSession = "none+i3";
  services.picom = {
    enable = true;
    settings = {
      backend = "glx";
      vsync = true;
    };
  };
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


  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    ohMyZsh = {
      theme = "robbyrussell";
      enable = true;
      plugins = [ ];
    };
  };

  programs.neovim.enable = true;
  environment.variables.EDITOR = "nvim";
  environment.variables.GTK_THEME = "Adwaita:dark";
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
      "includeIf \"gitdir:/home/ncarchar/gatech/**\"" = {
        path = "/home/ncarchar/gatech/.gitconfig";
      };
    };
  };

  services.ollama = {
    enable = true;
    acceleration = "rocm";
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
