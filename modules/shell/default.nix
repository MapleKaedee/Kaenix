{
  lib,
  pkgs,
  globals,
  ...
}:
{
  imports = [
    ./fish.nix
    ./nushell.nix
    ./common.nix
    ./fastfetch.nix
    ./git.nix
  ];

  users.users.${globals.username}.shell = import ../../lib/shell-package.nix {
    inherit lib pkgs;
    name = globals.defaultShell;
  };
}
