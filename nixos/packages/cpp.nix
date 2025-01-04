{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    autoconf
    automake
    bison
    clang
    cmake
    flex
    gcc
    gcc11
    gnumake
    libstdcxx5
    libtool
    makeWrapper
    pkg-config
  ];
}
