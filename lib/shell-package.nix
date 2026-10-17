# Keep login and terminal shell selection consistent.
{ lib, pkgs, name }:
assert lib.assertMsg (builtins.elem name [ "fish" "nushell" ])
  "kaenix: globals.defaultShell must be either \"fish\" or \"nushell\".";
pkgs.${name}
