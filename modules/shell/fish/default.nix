{ pkgs, globals, ... }:
{
  programs.fish.enable = true;
  environment.shells = [ pkgs.fish ];
  home-manager.users.${globals.username}.imports = [ ./home.nix ];
}
