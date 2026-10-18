{ pkgs, ... }:
{
  home.packages = [
    pkgs.pavucontrol
    pkgs.easyeffects
  ];
}
