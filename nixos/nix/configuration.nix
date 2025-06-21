{ pkgs, ... }:
let
  packages = import ./packages.nix { pkgs = pkgs; };
in
{
  imports = [
    ./vm.nix
  ];
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  /* 64 MiB download buffer */
  nix.settings.download-buffer-size = 67108864;
  system.stateVersion = "25.05";
  programs.nix-ld.enable = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  /* boot loader */
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;

  /* network manager */
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  /* locale */
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  location = {
    provider = "manual";
    longitude = -80.0;
    latitude = 40.0;
  };

  /* packages */
  environment.systemPackages = packages.dev ++ packages.temp ++ packages.desktop;

  /* docker */
  virtualisation.docker.enable = true;

  /* user */
  users.users.ncarchar = {
    isNormalUser = true;
    home = "/home/ncarchar";
    description = "Carson Miller";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "docker" ];
  };
  users.defaultUserShell = pkgs.zsh;

  /* gnome keyring */
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.gdm.enableGnomeKeyring = true;
  security.pam.services.gdm-password.enableGnomeKeyring = true;

  /* picom */
  services.picom = {
    enable = true;
    settings = {
      backend = "glx";
      vsync = true;
    };
  };

  /* xerver + i3 */
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

  /* fonts */
  fonts = {
    fontconfig = {
      defaultFonts = {
        serif = [ "Liberation Serif" "Vazirmatn" ];
        sansSerif = [ "Ubuntu" "Vazirmatn" ];
        monospace = [ "Berkeley Mono" ];
      };
    };
  };

  /* audio */
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  /* printer */
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  /* display auto dimming */
  services.redshift = {
    enable = true;
    temperature.night = 5000;
    temperature.day = 6500;
    brightness.night = "0.9";
    brightness.day = "1";
  };

  /* programs */
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

}
