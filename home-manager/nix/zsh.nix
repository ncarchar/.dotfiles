{ config, pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initExtra = "export PATH=$HOME/.scripts:$PATH\neval \"$(zoxide init zsh)\"";
    oh-my-zsh = {
      theme = "robbyrussell";
      enable = true;
      plugins = [ ];
    };
    shellAliases = {
      ls = "exa --across --group-directories-first";
      la = "exa --all --across  --group-directories-first";
      ll = "exa -l --all -g --icons --git --no-user --classify --group-directories-first";
      lt = "exa --level=1 --icons --tree --git --git-ignore --no-user --no-permissions --group-directories-first -a";
      lft = "exa --icons --tree --git --git-ignore --no-user --no-permissions --group-directories-first -a";
      hist = ". hist";
      tms = ". tms";
    };
  };
}

