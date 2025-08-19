{ pkgs, packages, homeDirectory, stateVersion, system, username }: {
  nix.package = pkgs.nix;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  home.username = username;
  home.homeDirectory = homeDirectory;
  news.display = "silent";

  home.stateVersion = stateVersion;

  home.packages = packages.dev;

  programs.neovim.enable = true;
  programs.starship = {
    enable = true;
  };

  programs.home-manager.enable = true;

  home.sessionVariables = {
    JAVA_HOME = "${pkgs.jdk}";
    JAVA_TOOL_OPTIONS = ''
      -Djavax.net.ssl.trustStore=${homeDirectory}/.certs-java/ca-trust.p12
      -Djavax.net.ssl.trustStorePassword=changeit
    '';
  };
}
