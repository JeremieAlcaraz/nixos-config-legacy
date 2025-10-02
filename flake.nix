{
  description = "Configuration NixOS avec Home Manager";

  nixConfig = {
    extra-substituters = [ "https://jeremiealcaraz.cachix.org" ];
    extra-trusted-public-keys = [
      "jeremiealcaraz.cachix.org-1:9UgJGpTOkYGiRAhNrB+3qcmfJlW3WB9EjjeWZJkuvs="
    ];
    experimental-features = [ "nix-command" "flakes" ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vicinae = {
      url = "github:vicinaehq/vicinae";
    };

    neovim = {
      url = "git+https://gitlab.com/jeremiealcaraz/nyanvim.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, vicinae, ... } @ inputs:
    let
      mkFormatter = system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        pkgs.writeShellApplication {
          name = "fmt";
          runtimeInputs = [ pkgs.nixpkgs-fmt pkgs.findutils ];
          text = builtins.readFile ./scripts/fmt.sh;
        };
    in
    rec {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./host/nixos/configuration.nix

            ({ pkgs, ... }: {
              programs.nix-ld = {
                enable = true;
                libraries = with pkgs; [
                  stdenv.cc.cc
                  zlib
                  curl
                  openssl
                ];
              };
              users.users.jeremie.linger = true;
            })

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.jeremie = import ./home-manager/home.nix;
            }
          ];
        };
      };

      formatter = {
        x86_64-linux = mkFormatter "x86_64-linux";
        aarch64-darwin = mkFormatter "aarch64-darwin";
      };
    };
}
