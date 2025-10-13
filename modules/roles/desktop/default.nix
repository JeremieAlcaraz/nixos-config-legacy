{ pkgs, ... }:
{
  networking = {
    networkmanager.enable = true;
    useNetworkd = false;
    useDHCP = false;
    dhcpcd.enable = false;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  services.getty.autologinUser = "jeremie";

  environment.loginShellInit = ''
    if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
      exec niri --session
    fi
  '';

  programs.niri.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  environment.systemPackages = with pkgs; [
    git
    neovim
    wl-clipboard
    swaybg
    xwayland-satellite
    waybar
    alacritty
    fuzzel
    swaylock
    brightnessctl
  ];
}
