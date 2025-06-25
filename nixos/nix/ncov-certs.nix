{ pkgs, ... }:
{
  home.packages = [ pkgs.jdk ];

  home.sessionVariables = {
    JAVA_HOME = "${pkgs.jdk}";
    JAVA_TOOL_OPTIONS = ''
      -Djavax.net.ssl.trustStore=/home/cvhew/.certs-java/ca-trust.p12
      -Djavax.net.ssl.trustStorePassword=changeit
    '';
  };
}
