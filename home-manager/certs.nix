{ config, pkgs, lib, ... }:
let
  certsDir = "${config.xdg.configHome}/.certs";
  javaTrustStore = "${certsDir}/cacerts";
  certUrls = [
    "https://zcert.covestro.net/ZscalerCloudCovestroCA.crt"
    "http://pki-services.covestro.net/grouppki/covestro_serverca.cer"
    "http://pki-services.covestro.net/grouppki/covestro_rootca.cer"
    "https://repo.maven.apache.org/maven2/"
    "https://covestro-618253301100.d.codeartifact.us-east-1.amazonaws.com"
  ];
in
{
  home.packages = with pkgs; [
    jdk21
    curl
    openssl
    gawk
  ];

  home.activation.createCerts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    echo "Initializing custom CA certificates..."

    if [ "$LOAD_CERTS" = "1" ]; then
      mkdir -p ${certsDir}

      if [[ $HOSTNAME = COV* ]]; then
        echo "Fetching certificates..."

        CURL=${pkgs.curl}/bin/curl
        AWK=${pkgs.gawk}/bin/awk
        KEYTOOL=${pkgs.jdk21}/bin/keytool
        OPENSSL=${pkgs.openssl}/bin/openssl

        for url in ${lib.concatStringsSep " " (map (u: "\"${u}\"") certUrls)}; do
          if [[ "$url" != *.crt && "$url" != *.cer ]]; then
            echo "Fetching certificate from $url using openssl..."
            domain=$(echo "$url" | $AWK -F/ '{print $3}')
            alias=domain
            dest="${certsDir}/$domain.pem"
            $OPENSSL s_client -showcerts -servername "$domain" -connect "$domain:443" < /dev/null 2>/dev/null | $OPENSSL x509 -outform PEM > "$dest"
          else
            filename=$(basename "$url")
            alias="cert-$(basename "$filename" .crt)"
            dest="${certsDir}/$filename"
            echo "Downloading certificate from $url..."
            $CURL -k -o "$dest" "$url"
          fi

          if [ -f "$dest" ]; then
            echo "Checking if alias $alias already exists in keystore..."
            if $KEYTOOL -list -keystore "${javaTrustStore}" -storepass changeit -alias "$alias" >/dev/null 2>&1; then
              echo "Certificate $alias exists; deleting..."
              $KEYTOOL -delete -alias "$alias" -keystore "${javaTrustStore}" -storepass changeit
            fi

            echo "Importing certificate ($dest) as $alias..."
            $KEYTOOL -importcert -trustcacerts -keystore "${javaTrustStore}" -storepass changeit -noprompt -alias "$alias" -file "$dest"
          else
            echo "Failed to obtain certificate from $url"
          fi
        done

        echo "Custom CA certificates setup completed."
      fi
    else
      echo "Skipping certificate fetching due to LOAD_CERTS flag."
    fi
  '';

  home.sessionVariables = {
    JAVA_TOOL_OPTIONS = "-Djavax.net.ssl.trustStore=${javaTrustStore} -Djavax.net.ssl.trustStorePassword=changeit";
  };
}
