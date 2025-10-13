{ lib, ... }:
{
  networking = {
    networkmanager.enable = lib.mkDefault false;
    useNetworkd = lib.mkDefault true;
    useDHCP = lib.mkDefault true;
    dhcpcd.enable = lib.mkDefault false;
    firewall = {
      enable = lib.mkDefault true;
      allowedTCPPorts = [ 22 ];
    };
  };

  services.qemuGuest.enable = true;
  services.cloud-init.enable = true;
}
