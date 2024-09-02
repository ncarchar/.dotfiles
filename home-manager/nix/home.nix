{ config, pkgs, ... }:
{
  home.username = "ncarchar";
  home.homeDirectory = "/home/ncarchar";
  home.stateVersion = "24.05";
  home.file = {
    ".config/nvim".source = ./../_nvim/nvim;
    ".config/waybar".source = ./../_waybar/waybar;
    ".config/hypr".source = ./../_hypr/hypr;
    ".prettierrc".source = ./../_prettier/.prettierrc;
    ".scripts".source = ./../_scripts/.scripts;
    ".tmux.conf".source = ./../_tmux/.tmux.conf;
    ".config/sway".source = ./../_sway/sway;
    ".alacritty.toml".source = ./../_alacritty/.alacritty.toml;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
