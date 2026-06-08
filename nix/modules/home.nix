{ pkgs, packages, homeDirectory, stateVersion, username }: {
  nix.package = pkgs.nix;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  home.username = username;
  home.homeDirectory = homeDirectory;
  news.display = "silent";

  home.stateVersion = stateVersion;

  home.packages = packages.core ++ packages.dev;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
  xdg.configFile."nvim/init.lua" = {
    source = ../../home/_nvim/.config/nvim/init.lua;
    force = true;
  };


  programs.starship = {
    enable = true;
  };

  programs.home-manager.enable = true;
  home.shell.enableBashIntegration = true;
}
