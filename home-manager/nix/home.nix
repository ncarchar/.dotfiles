{ config, pkgs, ... }:
{
  home.username = "ncarchar";
  home.homeDirectory = "/home/ncarchar";
  home.stateVersion = "24.05";
  home.file = {
    ".config/nvim".source = ./../_nvim/nvim;
    ".prettierrc".source = ./../_prettier/.prettierrc;
    ".scripts".source = ./../_scripts/.scripts;
    ".tmux.conf".source = ./../_tmux/.tmux.conf;
    ".config/i3".source = ./../_i3/i3;
    ".config/i3blocks".source = ./../_i3blocks/i3blocks;
    ".alacritty.toml".source = ./../_alacritty/.alacritty.toml;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.git = {
    enable = true;
    userName = "ncarchar";
    userEmail = "carsoncmiller@proton.me";
  };
}
