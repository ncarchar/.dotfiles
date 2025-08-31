{ pkgs, ... }:
{
  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [
    virtualbox
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    win-virtio
    win-spice
  ];
  virtualisation = {
    virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    spiceUSBRedirection.enable = true;
  };
  services.spice-vdagentd.enable = true;
}
