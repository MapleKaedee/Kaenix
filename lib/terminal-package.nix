# Keep desktop terminal selection consistent.
{
  lib,
  pkgs,
  name,
}:
assert lib.assertMsg (builtins.elem name [
  "alacritty"
  "kitty"
]) "kaenix: globals.defaultTerminal must be either \"alacritty\" or \"kitty\".";
pkgs.${name}
