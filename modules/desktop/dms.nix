{ ... }:
{
  flake.modules.nixos.dms =
    { globals, ... }:
    {
      nixpkgs.overlays = [
        (_final: prev: {
          # The pinned Sphinx hook reads only the first item of a structured array.
          khal = prev.khal.overrideAttrs (_: {
            sphinxBuilders = "html man";
          });
        })
      ];

      services.displayManager.dms-greeter = {
        enable = true;
        compositor.name = "niri";
        configHome = "/home/${globals.username}";
      };
      services.displayManager.defaultSession = "niri";
      services.displayManager.autoLogin.enable = false;
      security.pam.services.dankshell = { };
      home-manager.users.${globals.username} =
        {
          config,
          pkgs,
          inputs,
          ...
        }:
        let
          videoName = "moonlit-blade-of-the-white-dragon.3840x2160.mp4";
          wallpaper = "${config.home.homeDirectory}/Pictures/Wallpapers/${videoName}";
          settings = import ../../config/dms/settings.nix { configHome = config.xdg.configHome; };
          pluginSettings = {
            catWidget.enabled = true;
            mpvpaper = {
              enabled = true;
              videoLibrary = [ wallpaper ];
              monitorVideos."eDP-2" = wallpaper;
              videoSettings.${wallpaper}.panscan = 0.5;
              pauseOnFullscreen = true;
            };
          };
          json = name: value: pkgs.writeText name (builtins.toJSON value);
        in
        {
          programs.dank-material-shell = {
            enable = true;
            systemd.enable = true;
            systemd.target = "niri.service";
            enableDynamicTheming = true;
            enableSystemMonitoring = true;
            # GUI state must stay writable. The official settings/session options create store symlinks.
            managePluginSettings = false;
            plugins = {
              catWidget.src = inputs.cat-widget;
              mpvpaper.src = inputs.mpvpaper-plugin;
            };
          };
          home.file."Pictures/Wallpapers/${videoName}".source = ../../collection + "/${videoName}";
          kaenix.seedFiles = [
            {
              target = ".config/dms/settings.json";
              source = json "dms-settings.json" settings;
            }
            {
              target = ".config/dms/plugin_settings.json";
              source = json "dms-plugins.json" pluginSettings;
            }
            {
              target = ".local/state/dms/session.json";
              source = json "dms-session.json" { showThirdPartyPlugins = true; };
            }
            {
              target = ".config/dms/themes/catppuccin/theme.json";
              source = ../../config/dms/catppuccin.json;
            }
          ];
        };
    };
}
