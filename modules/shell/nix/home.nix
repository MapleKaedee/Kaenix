{ pkgs, ... }:
{
  home.packages = [
    pkgs.nix-output-monitor
    pkgs.nixfmt
  ];
}
