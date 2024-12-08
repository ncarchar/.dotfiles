{ config, pkgs, ... }:
let
  vfioIds = [ "1002:744c" "1002:ab30" ];
in {
  imports =
    [
      /etc/nixos/hardware-configuration.nix
      /etc/nixos/system-packages.nix
      /etc/nixos/vm.nix
      /etc/nixos/zsh.nix
    ];
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  programs.nix-ld.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  # boot.kernelModules = [ "vfio" "vfio_iommu_type1" "vfio_pci" "vfio_virqfd" ];
  # boot.kernelParams = [
  #   "vfio-pci.ids=${builtins.concatStringsSep "," vfioIds}"
  #   "amd_iommu=pt"
  #   "iommu=pt"
  # ];

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [ mesa ];
    driSupport32Bit = true;
  };

  networking.nameservers = [
    "45.90.28.0#894bc3.dns.nextdns.io"
    "2a07:a8c0::#894bc3.dns.nextdns.io"
    "45.90.30.0#894bc3.dns.nextdns.io"
    "2a07:a8c1::#894bc3.dns.nextdns.io"
  ];

  services.resolved = {
    enable = true;
    dnssec = "true";
    dnsovertls = "true";
    domains = [ "~." ];
    fallbackDns = [
      "45.90.28.0#894bc3.dns.nextdns.io"
      "2a07:a8c0::#894bc3.dns.nextdns.io"
    ];
  };

  # networking.nameservers = [
  #   "8.8.8.8"
  #   "8.8.4.4"
  # ];

  # services.resolved = {
  #   enable = true;
  #   dnssec = "true";
  #   dnsovertls = "true";
  #   domains = [ "~." ];
  #   fallbackDns = [
  #     "8.8.8.8"
  #     "8.8.4.4"
  #   ];
  # };
  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  virtualisation.docker.enable = true;

  users.users.ncarchar = {
    isNormalUser = true;
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

  system.stateVersion = "24.05";

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.gdm.enableGnomeKeyring = true;
  security.pam.services.gdm-password.enableGnomeKeyring = true;

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    xwayland.enable = true;
  };
  programs.seahorse.enable = true;
  programs.dconf.enable = true;
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
