{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    cargo
    go
    jdk21
    maven
    nodePackages."@angular/cli"
    nodePackages."eslint"
    nodePackages."http-server"
    nodePackages."prettier"
    nodePackages."typescript"
    nodejs
    rustc
    zig
    python312Packages.huggingface-hub
    (python3.withPackages (ps: with ps; [
      pip
      i3ipc
    ]))
  ];
}
