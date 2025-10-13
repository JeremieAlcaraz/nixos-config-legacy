{ config, pkgs, ... }:
{
  # ╭────────────────────── LOGS & KERNEL ──────────────────╮
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelParams = [ "loglevel=4" "quiet" ];
    consoleLogLevel = 4;
    kernel.sysctl = {
      "kernel.printk" = "4 4 1 7";
    };
  };

  services.journald = {
    extraConfig = ''
      MaxLevelStore=notice
      MaxLevelKMsg=warning
      Storage=persistent
      Compress=yes
      SystemMaxUse=500M
      RuntimeMaxUse=100M
      MaxRetentionSec=1week
    '';
  };

  # ╭────────────────────── LOCALISATION ───────────────────╮
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  # ╭────────────────────── CLAVIER & CONSOLE ──────────────╮
  services.xserver.xkb = {
    layout = "fr";
    variant = "azerty";
  };
  console.keyMap = "fr";

  # ╭────────────────────── UTILISATEURS ───────────────────╮
  users.users.jeremie = {
    isNormalUser = true;
    description = "jeremie";
    extraGroups = [ "networkmanager" "wheel" "video" "input" "seat" ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;

  # ╭────────────────────── SUDO ───────────────────────────╮
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # ╭────────────────────── PACKAGES SYSTÈME ───────────────╮
  nixpkgs.config.allowUnfree = true;

  services.tailscale = {
    enable = true;
    openFirewall = true;
  };
  services.openssh.enable = true;
  services.dbus.enable = true;

  programs.git = {
    enable = true;
    config.user = {
      name = "JeremieAlcaraz";
      email = "hello@jeremiealcaraz.com";
    };
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };
}
