{
  description = "system flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { nixpkgs, nix-index-database, home-manager, ... }:
    let
      system = "x86_64-linux";
      stateVersion = "25.05";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./nix/hardware-configuration.nix
          ./nix/configuration.nix
          nix-index-database.nixosModules.nix-index
          ({ pkgs, ... }: {
            _module.args = {
              packages = import ./nix/packages.nix { inherit pkgs; };
              stateVersion = stateVersion;
            };
          })
        ];
      };
      homeConfigurations."cvhew" =
        let
          username = "cvhew";
          homeDirectory = "/home/${username}";
          packages = import ./nix/packages.nix { inherit pkgs; };
          home = import ./nix/home.nix {
            inherit pkgs packages homeDirectory stateVersion system username;
          };
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ home ];
        };
    };
}
