{ pkgs, globals, ... }:
{
  programs.nushell.enable = true;
  environment.shells = [ pkgs.nushell ];
  home-manager.users.${globals.username}.imports = [ ./home.nix ];
}
