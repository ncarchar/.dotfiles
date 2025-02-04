{ pkgs, ... }:
let
  user = builtins.getEnv "USER";
  homeDir = "/home/${user}";
  packages = import "${homeDir}/.dotfiles/nixos/nix/packages.nix" { pkgs = pkgs; };
in
{
  imports = [ "${homeDir}/.dotfiles/home-manager/certs.nix" ];
  home.username = user;
  home.homeDirectory = homeDir;

  home.stateVersion = "24.11";

  home.packages = packages.dev ++ packages.lang;

  home.sessionVariables = {
    EDITOR = "neovim";
  };

  programs.git.diff-so-fancy.enable = true;
  programs.neovim.enable = true;
  programs.zsh =
    {
      enable = true;
      dotDir = ".zsh-nix";
      initExtra = "export PATH=\"$HOME/.nix-profile/bin:$PATH\"\nsource ~/.zshrc";
      autosuggestion = {
        enable = true;
        strategy = [ "match_prev_cmd" ];
      };
      syntaxHighlighting.enable = true;
      history.extended = true;
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "colorize" ];
        theme = "robbyrussell";
      };
    };

  programs.home-manager.enable = true;
}
