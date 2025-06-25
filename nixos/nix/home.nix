{ pkgs, packages, homeDirectory, stateVersion, system, username }:
{
  # imports = lib.optional (builtins.match "COV.*" hostname != null) certsPath;
  home.username = username;
  home.homeDirectory = homeDirectory;

  home.stateVersion = "25.05";

  home.packages = packages.dev;

  home.sessionVariables = { EDITOR = "nvim"; };

  programs.neovim.enable = true;
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    dotDir = ".zsh-nix";
    initContent = ''
      export PATH="$HOME/.nix-profile/bin:$PATH"
      export PATH="${pkgs.starship}/bin:$PATH"
      source ~/.zshrc
    '';
    autosuggestion = {
      enable = true;
      strategy = [ "match_prev_cmd" ];
    };
    oh-my-zsh = { enable = true; };
    syntaxHighlighting.enable = true;
    history.extended = true;
  };

  programs.home-manager.enable = true;
}
