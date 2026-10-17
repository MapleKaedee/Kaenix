# System user account and default shell
{ lib, pkgs, globals, ... }:
{
  users.users.${globals.username} = {
    isNormalUser = true;
    description = globals.username;
    extraGroups = [ "networkmanager" "wheel" ];
    shell = import ../../lib/shell-package.nix { inherit lib pkgs; name = globals.defaultShell; };
  };

  programs.fish.enable = true;
  programs.nushell.enable = true;
  environment.shells = [ pkgs.fish pkgs.nushell ];
}
