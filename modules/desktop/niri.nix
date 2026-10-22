{ ... }:
{
  flake.modules.nixos.niri =
    {
      lib,
      pkgs,
      globals,
      ...
    }:
    let
      terminal = import ../../lib/terminal-package.nix {
        inherit lib pkgs;
        name = globals.defaultTerminal;
      };
      terminalName = lib.getName terminal;
      terminalDesktop = if terminalName == "alacritty" then "Alacritty.desktop" else "kitty.desktop";
    in
    {
      programs.niri.enable = true;
      programs.niri.package = pkgs.niri;
      environment.sessionVariables.TERMINAL = terminalName;
      home-manager.users.${globals.username} =
        # Static base in the store; DMS owns the writable fragments under niri/dms.
        { lib, ... }:
        {
          xdg.terminal-exec = {
            enable = true;
            settings.default = [ terminalDesktop ];
          };
          xdg.configFile."niri/config.kdl".text = builtins.readFile ../../config/niri/config.kdl;
          kaenix.seedFiles = map (name: {
            target = ".config/niri/dms/${name}";
            source = ../../config/niri/dms + "/${name}";
          }) (lib.attrNames (builtins.readDir ../../config/niri/dms));
        };
    };
}
