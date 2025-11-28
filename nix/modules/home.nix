{ pkgs, packages, homeDirectory, stateVersion, username }: {
  nix.package = pkgs.nix;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  home.username = username;
  home.homeDirectory = homeDirectory;
  news.display = "silent";

  home.stateVersion = stateVersion;

  home.packages = packages.core ++ packages.dev;

  programs.neovim.enable = true;
  programs.starship = {
    enable = true;
  };

  programs.home-manager.enable = true;
  home.shell.enableBashIntegration = true;
}
