{ config, pkgs, ... }:
{
  home.username = "cvhew";
  home.homeDirectory = "/home/cvhew";
  home.stateVersion = "24.05";
  home.file = {
    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    ".config/nvim".source = ./../../_nvim/nvim;
    ".prettierrc".source = ./../../_prettier/.prettierrc;
    ".scripts".source = ./../../_scripts/.scripts;
    ".tmux.conf".source = ./../../_tmux/.tmux.conf;
    ".alacritty.toml".source = ./../../_alacritty/.alacritty.toml;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "cvhew";
    userEmail = "carson.miller@covestro.com";
  };
}
