{ config, pkgs, lib, ... }:
let
  certsDir = "${config.xdg.configHome}/.certs";
  javaTrustStore = "${certsDir}/cacerts";
  certUrls = [
    "https://zcert.covestro.net/ZscalerCloudCovestroCA.crt"
    "http://pki-services.covestro.net/grouppki/covestro_serverca.cer"
    "http://pki-services.covestro.net/grouppki/covestro_rootca.cer"
    "https://repo.maven.apache.org/maven2/"
  ];
in
{
  home.packages = with pkgs; [
    jdk21
    curl
    openssl
  ];

  home.activation.createCerts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    echo "Initializing custom CA certificates..."
    if [ -n "$SKIP_CERTS" ]; then
        echo "Skipping certificate fetching due to SKIP_CERTS flag."
        exit 0
    fi
    mkdir -p ${certsDir}
    if [[ $HOSTNAME != COV* ]]; then
      exit 0
    fi
    CURL=${pkgs.curl}/bin/curl
    KEYTOOL=${pkgs.jdk21}/bin/keytool
    OPENSSL=${pkgs.openssl}/bin/openssl

    for url in ${lib.concatStringsSep " " (map (u: "\"${u}\"") certUrls)}; do
      if [[ "$url" != *.crt && "$url" != *.cer ]]; then
        echo "Fetching certificate from $url using openssl..."
        alias="cert-repo-maven"
        dest="${certsDir}/repo.maven.apache.org.pem"
         $OPENSSL s_client -showcerts -servername repo.maven.apache.org -connect repo.maven.apache.org:443 < /dev/null 2>/dev/null | $OPENSSL x509 -outform PEM > "$dest"
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
  '';

  home.sessionVariables = {
    JAVA_TOOL_OPTIONS = "-Djavax.net.ssl.trustStore=${javaTrustStore} -Djavax.net.ssl.trustStorePassword=changeit";
  };
}
