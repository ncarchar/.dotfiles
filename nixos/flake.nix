{
  description = "NixOS system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nix-index-database, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      username = "cvhew";
      homeDirectory = "/home/${username}";
      stateVersion = "25.05";
      packages = ./nix/packages.nix { pkgs = pkgs; };
      home = import ./nix/home.nix {
        inherit pkgs packages homeDirectory stateVersion system username;
      };
    in {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./nix/configuration.nix
          ./nix/hardware-configuration.nix
          nix-index-database.nixosModules.nix-index
        ];
      };
      homeConfigurations."cvhew@COV-63098830610" =
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ home ];
        };
    };
}
