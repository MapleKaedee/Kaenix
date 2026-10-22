{ ... }:
{
  flake.modules.nixos.kitty =
    { globals, ... }:
    {
      home-manager.users.${globals.username} =
        { lib, pkgs, ... }:
        {
          programs.kitty = {
            enable = true;
            font = {
              name = "JetBrainsMono Nerd Font Mono";
              size = 12;
            };
            shellIntegration.enableFishIntegration = true;
            settings = {
              shell = "${
                lib.getExe (
                  import ../../../lib/shell-package.nix {
                    inherit lib pkgs;
                    name = globals.defaultShell;
                  }
                )
              } --login";
              bold_font = "auto";
              italic_font = "auto";
              bold_italic_font = "auto";
              window_padding_width = 12;
              background_opacity = "0.5";
              background_blur = 25;
              hide_window_decorations = true;
              cursor_shape = "block";
              cursor_blink_interval = 1;
              scrollback_lines = 3000;
              copy_on_select = true;
              strip_trailing_spaces = "smart";
              tab_bar_style = "powerline";
              tab_bar_align = "left";
            };
            keybindings = {
              "ctrl+shift+n" = "new_window";
              "ctrl+t" = "new_tab";
              "ctrl+plus" = "change_font_size all +1.0";
              "ctrl+minus" = "change_font_size all -1.0";
              "ctrl+0" = "change_font_size all 0";
            };
            extraConfig = ''
              include dank-tabs.conf
              include dank-theme.conf
            '';
          };
          kaenix.seedFiles = [
            {
              target = ".config/kitty/dank-tabs.conf";
              source = ../../../config/kitty/dank-tabs.conf;
            }
            {
              target = ".config/kitty/dank-theme.conf";
              source = ../../../config/kitty/dank-theme.conf;
            }
          ];
        };
    };
}
