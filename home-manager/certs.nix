{ config, pkgs, lib, ... }:
let
  certsDir = "${config.xdg.configHome}/.certs";
  javaTrustStore = "${certsDir}/cacerts";
  certUrls = [
    "https://zcert.covestro.net/ZscalerCloudCovestroCA.crt"
    "http://pki-services.covestro.net/grouppki/covestro_serverca.cer"
    "http://pki-services.covestro.net/grouppki/covestro_rootca.cer"
  ];
in {
  home.packages = with pkgs; [
    jdk21
    curl
    coreutils
  ];

  home.activation.createCerts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    echo "Initializing custom CA certificates..."

    mkdir -p ${certsDir}

    # Use absolute path for curl from nixpkgs to ensure it's available
    CURL=${pkgs.curl}/bin/curl
    KEYTOOL=${pkgs.jdk21}/bin/keytool

    for url in ${lib.concatStringsSep " " (map (u: "\"${u}\"") certUrls)}; do
      filename=$(basename "$url")
      dest="${certsDir}/$filename"
      
      echo "Downloading certificate from $url..."
      $CURL -k -o "$dest" "$url"

      if [ -f "$dest" ]; then
        echo "Importing $filename into Java keystore..."
        $KEYTOOL -importcert -trustcacerts -keystore "${javaTrustStore}" -storepass changeit -noprompt -alias "cert-$(basename "$filename" .crt)" -file "$dest"
      else
        echo "Failed to download certificate from $url"
      fi
    done

    echo "Custom CA certificates setup completed."
  '';

  home.sessionVariables = {
    JAVA_TOOL_OPTIONS = "-Djavax.net.ssl.trustStore=${javaTrustStore} -Djavax.net.ssl.trustStorePassword=changeit";
  };

  # shellInit = ''
  #   export JAVA_TOOL_OPTIONS="-Djavax.net.ssl.trustStore=${javaTrustStore} -Djavax.net.ssl.trustStorePassword=changeit"
  # '';
}
