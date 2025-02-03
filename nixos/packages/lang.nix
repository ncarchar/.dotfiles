{ pkgs, ... }:
{
  langPackages = with pkgs; [
    cargo
    jdk21
    maven
    nodePackages."@angular/cli"
    nodePackages."eslint"
    nodePackages."prettier"
    nodePackages."typescript"
    nodePackages."aws-cdk"
    nodejs
    zig
    (python3.withPackages (ps: with ps; [
      pip
    ]))
  ];
}
