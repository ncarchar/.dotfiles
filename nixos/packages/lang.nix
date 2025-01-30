{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    cargo
    jdk21
    maven
    nodePackages."@angular/cli"
    nodePackages."eslint"
    nodePackages."prettier"
    nodePackages."typescript"
    nodejs
    rustc
    zig
    (python3.withPackages (ps: with ps; [
      pip
    ]))
  ];
}
