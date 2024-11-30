{ config, pkgs, ... }:
{
  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    promptInit = "export PATH=$HOME/.scripts:$PATH\neval \"$(zoxide init zsh)\"\nsource $HOME/.scripts/fzf-git.sh";
    ohMyZsh = {
      theme = "robbyrussell";
      enable = true;
      plugins = [ ];
    };
    shellAliases = {
      cp = "cp -a";
      ls = "exa --across --group-directories-first";
      la = "exa --all --across  --group-directories-first";
      ll = "exa -l --all -g --icons --git --no-user --classify --group-directories-first";
      lt = "exa --level=1 --icons --tree --git --git-ignore --no-user --no-permissions --group-directories-first -a";
      llt = "exa --level=2 --icons --tree --git --git-ignore --no-user --no-permissions --group-directories-first -a";
      lft = "exa --icons --tree --git --git-ignore --no-user --no-permissions --group-directories-first -a";
    };
  };
}
