{
  description = "Configuration NixOS avec Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # VS Code Server natif pour NixOS
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
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

  outputs = { self, nixpkgs, home-manager, vicinae, ... }@inputs:
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

            # Module VS Code Server (recommandé)
            inputs.vscode-server.nixosModules.default
            ({ ... }: {
              services.vscode-server.enable = true;
              # (Optionnel) compat binaire générique via nix-ld :
              # programs.nix-ld.enable = true;
            })

            # module Home-Manager
            home-manager.nixosModules.home-manager

            # glue pour charger la config user
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              # Ajoutez cette ligne pour passer inputs
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
