{
  description = "System Packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.${system} = {
      default = pkgs.neovim;

      sysPkgs = pkgs.buildEnv {
        name = "sysPkgs";
        paths = [
          pkgs.neovim
          pkgs.cargo
          pkgs.git
          pkgs.ripgrep
          pkgs.fzf
          pkgs.nodejs_22
          pkgs.nodePackages.prettier
        ];
      };
    };
  };
}
