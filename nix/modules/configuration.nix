{ pkgs, packages, stateVersion, ... }: {
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = stateVersion;
  nix.gc = {
    automatic = true;
    dates = "weekly";
  };

  # boot loader
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.timeout = 3;
  systemd.network.wait-online.enable = false;

  # network manager
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # locale
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # packages
  environment.systemPackages = packages.core ++ packages.dev
    ++ packages.desktop;

  # docker
  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = false;

  # user
  users.users.ncarchar = {
    isNormalUser = true;
    home = "/home/ncarchar";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "docker"
      "fuse"
      "vboxusers"
      "disk"
    ];
  };
  users.extraGroups.vboxusers.members = [ "ncarchar" ];

  # gnome keyring
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.gdm.enableGnomeKeyring = true;

  # sway
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
  };

  # noisetorch suppression
  programs.noisetorch.enable = true;
  systemd.user.services.wave3-init = {
    description = "Initialize Wave:3";
    bindsTo = [ "sys-subsystem-sound-wave3.device" ];
    after = [ "pipewire-pulse.service" "wireplumber.service" ];
    serviceConfig = {
      Type = "oneshot";
      Restart = "on-failure";
      RestartSec = "2s";
      StartLimitBurst = "3";
      ExecStart = pkgs.writeShellScript "init-wave3-audio" ''
        ${pkgs.noisetorch}/bin/noisetorch -u || true

        CARD=$(${pkgs.pulseaudio}/bin/pactl list cards short | ${pkgs.gnugrep}/bin/grep "Wave_3" | ${pkgs.gawk}/bin/awk '{print $2}')

        if [ -z "$CARD" ]; then exit 1; fi

        sleep 1
        ${pkgs.pulseaudio}/bin/pactl set-card-profile "$CARD" off
        sleep 1
        ${pkgs.pulseaudio}/bin/pactl set-card-profile "$CARD" input:mono-fallback
        sleep 1
        ${pkgs.noisetorch}/bin/noisetorch -i -t 95
        sleep 1
        ${pkgs.pulseaudio}/bin/pactl set-default-source "NoiseTorch Microphone for Elgato Wave:3"
      '';
    };
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="sound", ATTRS{id}=="Wave3", TAG+="systemd", ENV{SYSTEMD_USER_WANTS}+="wave3-init.service", ENV{ID_WAVE3_TRACKER}="1"
  '';

  # run unpatched dynamic binaries
  programs.nix-ld.enable = true;

  # programs
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
      init = { defaultBranch = "main"; };
      core = { pager = "less -F -X"; };
      push = { autoSetupRemote = true; };
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
}
