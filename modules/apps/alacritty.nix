{ globals, ... }:
{
  home-manager.users.${globals.username} =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      programs.alacritty = {
        enable = true;
        settings = {
          general.import = [ "${config.xdg.configHome}/alacritty/dank-theme.toml" ];
          terminal.shell = {
            program = lib.getExe (
              import ../../lib/shell-package.nix {
                inherit lib pkgs;
                name = globals.defaultShell;
              }
            );
            args = [ "--login" ];
          };
          font = {
            normal.family = "JetBrainsMono Nerd Font Mono";
            size = 12;
          };
          window = {
            padding = {
              x = 12;
              y = 12;
            };
            opacity = 0.9;
            decorations = "None";
          };
          scrolling.history = 3000;
          cursor = {
            style = {
              shape = "Block";
              blinking = "On";
            };
            blink_interval = 1000;
          };
          keyboard.bindings = [
            {
              key = "N";
              mods = "Control|Shift";
              action = "SpawnNewInstance";
            }
            {
              key = "+";
              mods = "Control";
              action = "IncreaseFontSize";
            }
            {
              key = "-";
              mods = "Control";
              action = "DecreaseFontSize";
            }
            {
              key = "0";
              mods = "Control";
              action = "ResetFontSize";
            }
          ];
        };
      };
      kaenix.seedFiles = [
        {
          target = ".config/alacritty/dank-theme.toml";
          source = ../../config/alacritty/dank-theme.toml;
        }
      ];
    };
}
