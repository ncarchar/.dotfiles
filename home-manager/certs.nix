{ config, pkgs, lib, ... }:

let
  certsDir = "${config.xdg.configHome}/.certs";
  javaTrustStore = "${certsDir}/cacerts";
  certUrls = [
    "https://zcert.covestro.net/ZscalerCloudCovestroCA.crt"
    "http://pki-services.covestro.net/grouppki/covestro_serverca.cer"
    "http://pki-services.covestro.net/grouppki/covestro_rootca.cer"
  ];
in
{
  home.packages = with pkgs; [
    jdk21
    curl
    coreutils
  ];

  home.activation.createCerts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    echo "Initializing custom CA certificates..."

    mkdir -p ${certsDir}

    # Use absolute paths for curl and keytool from nixpkgs
    CURL=${pkgs.curl}/bin/curl
    KEYTOOL=${pkgs.jdk21}/bin/keytool

    for url in ${lib.concatStringsSep " " (map (u: "\"${u}\"") certUrls)}; do
      filename=$(basename "$url")
      alias="cert-$(basename "$filename" .crt)"
      dest="${certsDir}/$filename"
      
      echo "Downloading certificate from $url..."
      $CURL -k -o "$dest" "$url"

      if [ -f "$dest" ]; then
        echo "Checking if alias $alias already exists in keystore..."
        
        if $KEYTOOL -list -keystore "${javaTrustStore}" -storepass changeit -alias "$alias" >/dev/null 2>&1; then
          echo "Certificate $alias already exists in keystore. Skipping import."
        else
          echo "Importing $filename into Java keystore..."
          $KEYTOOL -importcert -trustcacerts -keystore "${javaTrustStore}" -storepass changeit -noprompt -alias "$alias" -file "$dest"
        fi
      else
        echo "Failed to download certificate from $url"
      fi
    done

    echo "Custom CA certificates setup completed."
  '';

  home.sessionVariables = {
    JAVA_TOOL_OPTIONS = "-Djavax.net.ssl.trustStore=${javaTrustStore} -Djavax.net.ssl.trustStorePassword=changeit";
  };
}
