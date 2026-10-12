{
  pkgs,
  packages,
  stateVersion,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.stateVersion = stateVersion;
  nix.gc = {
    automatic = true;
    dates = "weekly";
  };

  # boot loader
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.timeout = 0;
  boot.initrd.systemd.enable = true;

  # Keep the dGPU (7900 XTX) out of runtime suspend; its BACO resume hangs.
  boot.kernelParams = [ "amdgpu.runpm=0" ];
  systemd.network.wait-online.enable = false;

  # network manager
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # locale
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # packages
  environment.systemPackages = packages.core ++ packages.dev ++ packages.desktop;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    DRI_PRIME = "1";
  };

  # docker
  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = false;

  # user
  users.users.ncarchar = {
    isNormalUser = true;
    home = "/home/ncarchar";
    extraGroups = [
      "dialout"
      "disk"
      "docker"
      "fuse"
      "libvirtd"
      "networkmanager"
      "vboxusers"
      "wheel"
    ];
  };

  # gnome keyring
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.gdm.enableGnomeKeyring = true;

  # xdg portals (file chooser / save-as for browsers on wlroots)
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = [
      "gtk"
      "wlr"
    ];
  };

  # sway
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      bemenu
      capitaine-cursors
      gammastep
      grim
      slurp
      swaybg
      waybar
      wl-clipboard
    ];
  };

  # fonts
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
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

  # audio
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.extraConfig = {
      "51-hdmi-default-profile"."monitor.alsa.rules" = [
        {
          matches = [ { "device.name" = "alsa_card.pci-0000_6c_00.1"; } ];
          actions.update-props."device.profile" = "output:hdmi-stereo";
        }
      ];
    };
  };

  # run unpatched dynamic binaries
  programs.nix-ld.enable = true;

  # programs
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.thunar = {
    enable = true;
    plugins = [ pkgs.thunar-archive-plugin ];
  };

  programs.steam.enable = true;
  hardware.steam-hardware.enable = true;

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

  hardware.keyboard.zsa.enable = true;
}
