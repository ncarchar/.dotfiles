{ pkgs }:

pkgs.writeShellApplication {
  name = "hello-world";
  runtimeInputs = [ pkgs.cowsay pkgs.lolcat ];
  text = ''
    #!/usr/bin/env bash
    echo "Hello, world!" | cowsay | lolcat
  '';
}
