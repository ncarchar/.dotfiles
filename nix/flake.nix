{
  description = "system flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { nixpkgs, nix-index-database, home-manager, ... }:
    let
      nixosSystem = "x86_64-linux";

      stateVersion = "25.11";

      nixosPackages = import ./modules/packages.nix {
        pkgs = import nixpkgs {

          system = nixosSystem;
          config.allowUnfree = true;
        };
      };

      covUsername = "cvhew";
      covDirectory = "/home/${covUsername}";
      covPkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      covPackages = import ./modules/packages.nix {
        pkgs = covPkgs;
      };
      covModule = import ./modules/home.nix {
        pkgs = covPkgs;
        packages = covPackages;
        stateVersion = stateVersion;
        username = covUsername;
        homeDirectory = covDirectory;
      };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = nixosSystem;
        modules = [
          ./modules/hardware-configuration.nix
          ./modules/configuration.nix
          nix-index-database.nixosModules.nix-index
          ({ pkgs, ... }: {
            _module.args = {
              packages = nixosPackages;
              inherit stateVersion;
            };
          })
        ];
      };

      homeConfigurations.${covUsername} =
        home-manager.lib.homeManagerConfiguration {
          pkgs = covPkgs;
          modules = [ covModule ];
        };
    };
}
