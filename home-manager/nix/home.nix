{ config, pkgs, ... }:
{
  home.username = "ncarchar";
  home.homeDirectory = "/home/ncarchar";
  home.stateVersion = "24.05";
  home.file = {
    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    ".config/nvim".source = ./../_nvim/nvim;
    ".prettierrc".source = ./../_prettier/.prettierrc;
    ".scripts".source = ./../_scripts/.scripts;
    ".tmux.conf".source = ./../_tmux/.tmux.conf;
    ".config/i3".source = ./../_i3/i3;
    ".config/i3blocks".source = ./../_i3blocks/i3blocks;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "ncarchar";
    userEmail = "carsoncmiller@proton.me";
  };
}
