{
  description = "system flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, unstable, nix-index-database, home-manager, ... }:
    let
      system = "x86_64-linux";
      stateVersion = "25.05";

      pkgs = import nixpkgs { inherit system; };

      unstablePkgs = import unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          ./modules/hardware-configuration.nix
          ./modules/configuration.nix
          ./modules/virtual-box.nix

          nix-index-database.nixosModules.nix-index

          ({ pkgs, ... }: {
            _module.args = {
              packages = import ./modules/packages.nix { inherit pkgs; };
              inherit stateVersion;
            };
          })

          ({ ... }: {
            services.ollama.package = unstablePkgs.ollama;
          })
        ];
      };
      homeConfigurations."cvhew" =
        let
          username = "cvhew";
          homeDirectory = "/home/${username}";
          packages = import ./modules/packages.nix { inherit pkgs; };
          home = import ./modules/home.nix {
            inherit pkgs packages homeDirectory stateVersion system username;
          };
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ home ];
        };
      homeConfigurations."mac" =
        let
          systemDarwin = "aarch64-darwin";
          pkgsDarwin = import nixpkgs { system = systemDarwin; };
          username = "carsonmiller";
          homeDirectory = "/Users/${username}";
          packages = import ./modules/packages.nix { pkgs = pkgsDarwin; };
          home = import ./modules/home.nix {
            pkgs = pkgsDarwin;
            inherit packages homeDirectory stateVersion username;
            system = systemDarwin;
          };
        in
        home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsDarwin;
          modules = [ home ];
        };
    };
}
