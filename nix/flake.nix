{
  description = "system flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    let
      stateVersion = "26.05";

      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

      mkHome =
        {
          system,
          username,
          homeDirectory,
        }:
        let
          pkgs = mkPkgs system;
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            (import ./modules/home.nix {
              inherit
                pkgs
                stateVersion
                username
                homeDirectory
                ;
              packages = import ./modules/packages.nix { inherit pkgs; };
            })
          ];
        };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./modules/hardware-configuration.nix
          ./modules/configuration.nix
          {
            _module.args = {
              inherit stateVersion;
              packages = import ./modules/packages.nix {
                pkgs = mkPkgs "x86_64-linux";
              };
            };
          }
        ];
      };

      homeConfigurations = {
        "cvhew" = mkHome {
          system = "x86_64-linux";
          username = "cvhew";
          homeDirectory = "/home/cvhew";
        };

        "mac" = mkHome {
          system = "aarch64-darwin";
          username = "ncarchar";
          homeDirectory = "/Users/ncarchar";
        };
      };
    };
}
