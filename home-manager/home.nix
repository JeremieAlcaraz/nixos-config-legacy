# Configuration utilisateur avec Home Manager
{ config, pkgs, ... }:

{
  # ╭──────────────────────────────────────────────────────────────╮
  # │                       IDENTITÉ UTILISATEUR                   │
  # ╰──────────────────────────────────────────────────────────────╯
  home.username      = "jeremie";
  home.homeDirectory = "/home/jeremie";

  # ╭──────────────────────────────────────────────────────────────╮
  # │                 PAQUETS SANS MODULE HOME-MANAGER             │
  # ╰──────────────────────────────────────────────────────────────╯
  home.packages = with pkgs; [
    # Outils de développement
    tailscale
    openssh
    gh
    cowsay

    # Utilitaires divers (sans module HM)
    tree
  ];

  # ╭──────────────────────────────────────────────────────────────╮
  # │                  PROGRAMMES AVEC MODULES HM                  │
  # ╰──────────────────────────────────────────────────────────────╯
  ## Git
  programs.git = {
    enable         = true;
    userName       = "JeremieAlcaraz";
    userEmail      = "hello@jeremiealcaraz.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase        = false;
    };
  };

  ## zoxide (cd intelligent)
  programs.zoxide.enable = true;

  ## eza (remplaçant moderne de ls)
  programs.eza.enable = true;

  ## navi (cheatsheets interactives)
  programs.navi.enable = true;

  programs.starship = {
  enable = true;                     # installe starship + complétions
  enableZshIntegration = true;       # l’injecte dans ton zsh
  # enableBashIntegration = true;    # (décommente si tu utilises bash)
  # enableFishIntegration = true;    # (idem pour fish)
};

  # ╭──────────────────────────────────────────────────────────────╮
  # │                      ÉDITEUR & OUTILS                        │
  # ╰──────────────────────────────────────────────────────────────╯
  programs.neovim = {
    enable         = true;
    defaultEditor  = true;
    viAlias        = true;
    vimAlias       = true;
  };

  # ╭──────────────────────────────────────────────────────────────╮
  # │                  CONFIGURATION DU SHELL ZSH                  │
  # ╰──────────────────────────────────────────────────────────────╯
  programs.zsh = {
    enable               = true;
    enableCompletion     = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ls  = "eza --group-directories-first --icons";
      ll  = "eza -l --git";
      la  = "eza -la --git";
      rebuild       = "sudo nixos-rebuild switch --flake ~/nix-config#nixos";
      rebuild-test  = "sudo nixos-rebuild test   --flake ~/nix-config#nixos";
      rebuild-boot  = "sudo nixos-rebuild boot   --flake ~/nix-config#nixos";
    };
  };

  # ╭──────────────────────────────────────────────────────────────╮
  # │                 VARIABLES & FICHIERS PERSONNELS              │
  # ╰──────────────────────────────────────────────────────────────╯
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.file = {
    # Cheatsheets Navi personnelles
    "${config.xdg.dataHome}/navi/cheats".source =
      ../modules/navi/cheats;

    # Exemple de dotfile (commenté)
    # ".config/example/config.yml".text = ''
    #   key: value
    # '';
  };

  # ╭──────────────────────────────────────────────────────────────╮
  # │                       MÉTA-CONFIG HM                         │
  # ╰──────────────────────────────────────────────────────────────╯
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}
