{ pkgs, ... }:
{
  boot.blacklistedKernelModules = [ "kvm-amd" "kvm-intel" "kvm" ];
  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [
  ];
  virtualisation = {
    virtualbox = {
      host = {
        enable = true;
        enableExtensionPack = true;
      };
    };
  };
}
