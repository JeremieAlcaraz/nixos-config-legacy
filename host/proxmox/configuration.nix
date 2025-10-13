{ ... }:
{
  imports = [
    ../../modules/system/ssh
    ../../modules/system/base/default.nix
    ../../modules/roles/proxmox/default.nix
    ../../modules/roles/desktop/default.nix
    ../../modules/storage/proxmox.nix
  ];

  networking.hostName = "nixos-proxmox";

  system.stateVersion = "25.05";
}
