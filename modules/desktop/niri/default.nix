{ pkgs, globals, ... }:
{
  programs.niri.enable = true;
  programs.niri.package = pkgs.niri;
  environment.systemPackages = [ pkgs.xwayland-satellite ];
  home-manager.users.${globals.username}.imports = [ ./home.nix ];
}
