{ pkgs, packages, stateVersion, ... }:
{
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  /* 64 MiB download buffer */
  nix.settings.download-buffer-size = 67108864;
  system.stateVersion = stateVersion;
  programs.nix-ld.enable = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
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

  /* packages */
  environment.systemPackages = packages.dev ++ packages.desktop;

  /* docker */
  virtualisation.docker.enable = true;

  /* user */
  users.users.ncarchar = {
    isNormalUser = true;
    home = "/home/ncarchar";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "docker" ];
  };
  users.defaultUserShell = pkgs.zsh;

  /* gnome keyring */
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.gdm.enableGnomeKeyring = true;

  services.libinput.mouse.tappingDragLock = false;

  /* wayland + sway */
  programs.sway = {
    enable = true;
    extraPackages = with pkgs; [
      bemenu
      i3status
      i3blocks
    ];
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd sway";
      };
    };
  };

  /* fonts */
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
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

  /* display auto dimming */
  # services.gammastep = {
  #   enable = true;
  #   temperature.night = 5000;
  #   temperature.day = 6500;
  #   brightness.night = "0.9";
  #   brightness.day = "1";
  # };

  /* programs */
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    autosuggestions.strategy = [ "match_prev_cmd" ];
    syntaxHighlighting.enable = true;
    ohMyZsh = {
      enable = true;
    };
  };
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [ thunar-archive-plugin ];
  };
  programs.steam.enable = true;
  programs.git = {
    enable = true;
    config = {
      core = {
        pager = "less -F -X";
      };
    };
  };
}
