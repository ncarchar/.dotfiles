{ pkgs, packages, stateVersion, ... }:
{
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = stateVersion;
  nix.gc = {
    automatic = true;
    dates = "weekly";
  };

  /* boot loader */
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.timeout = 3;
  systemd.network.wait-online.enable = false;

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
  virtualisation.docker.enableOnBoot = false;

  /* user */
  users.users.ncarchar = {
    isNormalUser = true;
    home = "/home/ncarchar";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "docker" "fuse" "vboxusers" "disk" ];
  };
  users.extraGroups.vboxusers.members = [ "ncarchar" ];

  /* gnome keyring */
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.gdm.enableGnomeKeyring = true;

  /* sway */
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      bemenu
      capitaine-cursors
      gammastep
      grim
      i3blocks
      slurp
      swaybg
      wl-clipboard
    ];
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

  /* run unpatched dynamic binaries */
  programs.nix-ld.enable = true;

  /* programs */
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
      init = {
        defaultBranch = "main";
      };
      core = {
        pager = "less -F -X";
      };
      push = {
        autoSetupRemote = true;
      };
    };
  };

  services.printing = {
    enable = true;
    drivers = [ pkgs.brlaser ];
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.open-webui = {
    enable = true;
    port = 3000;
  };
  services.ollama = {
    enable = true;
    acceleration = "rocm";
    rocmOverrideGfx = "11.0.0";
  };
}
