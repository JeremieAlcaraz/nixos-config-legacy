# Configuration NixOS pour VM Proxmox (QCOW2)
{ config, pkgs, lib, ... }:

{
  # Pas de hardware-configuration.nix pour une image générique
  # Le hardware sera détecté au boot

  # ╭────────────────────── BOOTLOADER UEFI ────────────────╮
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    # Kernel params optimisés pour VM
    kernelParams = [
      "console=tty0"
      "console=ttyS0,115200" # Serial console pour Proxmox
      "quiet"
    ];

    # Modules kernel nécessaires pour Proxmox
    initrd.availableKernelModules = [
      "virtio_pci"
      "virtio_scsi"
      "virtio_blk"
      "virtio_net"
      "9p"
      "9pnet_virtio"
    ];

    kernelModules = [ "kvm-intel" "kvm-amd" ];
  };

  # ╭──────────────────────── FILESYSTEM ───────────────────╮
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
    autoResize = true; # Auto-resize si disque agrandi
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
  };

  # Swap optionnel (désactivé par défaut)
  swapDevices = [ ];

  # ╭──────────────────────── RÉSEAU ───────────────────────╮
  networking = {
    hostName = "nixos-proxmox";
    useDHCP = lib.mkDefault true;
    networkmanager.enable = false; # Utilise systemd-networkd à la place
    useNetworkd = true;

    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ]; # SSH
    };
  };

  # Configuration réseau systemd
  systemd.network = {
    enable = true;
    networks."10-wan" = {
      matchConfig.Name = "en*";
      networkConfig.DHCP = "yes";
      dhcpV4Config.UseDNS = true;
    };
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

  console.keyMap = "fr";

  # ╭────────────────────── UTILISATEURS ───────────────────╮
  users.users.root = {
    # Mot de passe par défaut (à changer!)
    # Généré avec: mkpasswd -m sha-512
    hashedPassword = "$6$rounds=656000$YourHashHere"; # Change-moi!
    openssh.authorizedKeys.keys = [
      # Ajoute ta clé SSH publique ici
      # "ssh-ed25519 AAAAC3Nza... ton@email.com"
    ];
  };

  users.users.jeremie = {
    isNormalUser = true;
    description = "jeremie";
    extraGroups = [ "wheel" ];
    hashedPassword = "$6$rounds=656000$YourHashHere"; # Change-moi!
    openssh.authorizedKeys.keys = [
      # Ajoute ta clé SSH publique ici
    ];
  };

  # ╭────────────────────── SUDO ───────────────────────────╮
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # ╭────────────────────── SERVICES VM ────────────────────╮
  # QEMU Guest Agent (important pour Proxmox!)
  services.qemuGuest.enable = true;

  # Cloud-init pour configuration automatique
  services.cloud-init = {
    enable = true;
    network.enable = true;
  };

  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password"; # Clés SSH uniquement
      PasswordAuthentication = false;
    };
  };

  # ╭────────────────────── PACKAGES SYSTÈME ───────────────╮
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Outils de base
    vim
    git
    wget
    curl
    htop
    tmux

    # Outils réseau
    nettools
    inetutils

    # Monitoring
    lm_sensors
  ];

  # ╭────────────────────── NIX CONFIG ─────────────────────╮
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;

    # Utilise ton cache Cachix
    extra-substituters = [
      "https://jeremiealcaraz.cachix.org"
      "https://vicinae.cachix.org"
    ];
    extra-trusted-public-keys = [
      "jeremiealcaraz.cachix.org-1:9UgJGpTOkYGiRAhNrB+3qcmfJlW3WB9EjjeWZJkuvs="
      "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
    ];
  };

  # Garbage collection automatique
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # ╭────────────────────── OPTIMISATIONS VM ───────────────╮
  # Désactive les services inutiles en VM
  services.udisks2.enable = false;
  programs.dconf.enable = false;

  # Console série pour Proxmox
  systemd.services."serial-getty@ttyS0" = {
    enable = true;
    wantedBy = [ "getty.target" ];
  };

  # ╭──────────────────── STATE VERSION ────────────────────╮
  system.stateVersion = "24.05";
}
