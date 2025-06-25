{ pkgs, packages, homeDirectory, stateVersion, system, username }: {
  home.username = username;
  home.homeDirectory = homeDirectory;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  news.display = "silent";

  home.stateVersion = stateVersion;

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
