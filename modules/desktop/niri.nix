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
      environment.sessionVariables.TERMINAL = "xdg-terminal-exec";
      home-manager.users.${globals.username} =
        # Static base in the store; DMS owns the writable fragments under niri/dms.
        { config, lib, ... }:
        {
          xdg.terminal-exec = {
            enable = true;
            settings.default = [ terminalDesktop ];
          };
          # DMS can change the terminal after this initial preference is seeded.
          xdg.configFile."xdg-terminals.list".enable = false;
          xdg.configFile."niri/config.kdl".text = builtins.readFile ../../config/niri/config.kdl;
          kaenix.seedFiles = [
            {
              target = ".config/xdg-terminals.list";
              source = config.xdg.configFile."xdg-terminals.list".source;
            }
          ]
          ++ map (name: {
            target = ".config/niri/dms/${name}";
            source = ../../config/niri/dms + "/${name}";
          }) (lib.attrNames (builtins.readDir ../../config/niri/dms));
        };
    };
}
