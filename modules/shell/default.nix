{
  lib,
  pkgs,
  globals,
  ...
}:
{
  imports = [
    ./fish
    ./nushell
    ./common
    ./fastfetch
    ./git
    ./nix
    ./tools
  ];

  users.users.${globals.username}.shell = import ../../lib/shell-package.nix {
    inherit lib pkgs;
    name = globals.defaultShell;
  };
}
