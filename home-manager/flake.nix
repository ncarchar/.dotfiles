{
  description = "Nix Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations = {
        ncarchar = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./nix/home.nix
          ];
        };
      };
    };
}
