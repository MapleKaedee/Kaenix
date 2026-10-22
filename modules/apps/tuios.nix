{ globals, ... }:
{
  home-manager.users.${globals.username} =
    { lib, pkgs, ... }:
    let
      shell = import ../../lib/shell-package.nix {
        inherit lib pkgs;
        name = globals.defaultShell;
      };
      launcher = import ../../lib/terminal-session.nix { inherit lib pkgs shell; };
    in
    {
      # The package list owns installation; this feature owns desktop startup.
      programs.kitty.settings.shell = "${launcher}";
      programs.alacritty.settings.terminal.shell = {
        program = "${launcher}";
        args = [ ];
      };
    };
}
