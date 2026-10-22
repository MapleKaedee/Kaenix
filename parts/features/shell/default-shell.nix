{ ... }:
{
  flake.modules.nixos.default-shell =
    {
      lib,
      pkgs,
      globals,
      ...
    }:
    {
      users.users.${globals.username}.shell = import ../../../lib/shell-package.nix {
        inherit lib pkgs;
        name = globals.defaultShell;
      };
    };
}
