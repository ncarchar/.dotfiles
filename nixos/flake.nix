{
  description = "system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
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
      lib = pkgs.lib;
      packages = import ./nix/packages.nix { inherit pkgs; };
    in
    {
      nixosConfigurations.nixos =
        let
          configuration = import ./nix/configuration.nix {
            inherit pkgs packages stateVersion;
          };
          hardwareConfiguration = import ./nix/hardware-configuration.nix {
            inherit pkgs lib;
          };
        in
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            configuration
            hardwareConfiguration
            nix-index-database.nixosModules.nix-index
          ];
        };
      homeConfigurations."cvhew" =
        let
          username = "cvhew";
          homeDirectory = "/home/${ username}";
          covcerts = import ./nix/ncov-certs.nix {
            inherit pkgs lib;
          };
          home = import ./nix/home.nix {
            inherit pkgs packages homeDirectory stateVersion system username;
          };
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ home covcerts ];
        };
    };
}
