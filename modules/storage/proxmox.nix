{ lib, ... }:
{
  disko.devices = {
    disk.system = {
      type = "disk";
      device = lib.mkDefault "/dev/vda";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            priority = 1;
            size = "512MiB";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              extraArgs = [ "-n" "PROXMOXBOOT" ];
            };
          };
          swap = {
            priority = 2;
            size = "8GiB";
            content = {
              type = "swap";
              extraArgs = [ "-L" "proxmox-swap" ];
            };
          };
          root = {
            priority = 10;
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              extraArgs = [ "-L" "proxmox-root" ];
            };
          };
        };
      };
    };
  };

  # Disko will configure file systems and swap devices based on the
  # mountpoint declarations above. Additional mount options can be set here.
  disko.devices.disk.system.content.partitions.ESP.content.mountOptions = [
    "fmask=0077"
    "dmask=0077"
  ];

  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "virtio_blk"
    "virtio_scsi"
    "xhci_pci"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "virtio_pci" ];
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
