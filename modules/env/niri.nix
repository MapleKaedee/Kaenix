# Enable the Niri compositor at the system level
{ pkgs, ... }:
{
  programs.niri.enable = true;
  programs.niri.package = pkgs.niri;
  environment.systemPackages = [ pkgs.xwayland-satellite ];
}
