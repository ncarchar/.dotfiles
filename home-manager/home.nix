{ pkgs, ... }:
let
  user = builtins.getEnv "USER";
  homeDir = "/home/${user}";
  core = import "${homeDir}/.dotfiles/nixos/packages/core.nix" { pkgs = pkgs; };
  lang = import "${homeDir}/.dotfiles/nixos/packages/lang.nix" { pkgs = pkgs; };
in
{
  home.username = user;
  home.homeDirectory = homeDir;

  home.stateVersion = "24.11";

  home.packages = core.corePackages ++ lang.langPackages;

  home.sessionVariables = {
    EDITOR = "neovim";
  };

  programs.neovim.enable = true;
  programs.zsh =
    {
      enable = true;
      dotDir = "~";
      initExtra = "source ~/.zshrc";
      autosuggestion.enable = true;
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" ];
        theme = "robbyrussell";
      };
    };

  programs.home-manager.enable = true;
}
