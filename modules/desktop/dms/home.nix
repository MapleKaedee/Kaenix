{
  config,
  pkgs,
  inputs,
  ...
}:
let
  videoName = "moonlit-blade-of-the-white-dragon.3840x2160.mp4";
  wallpaper = "${config.home.homeDirectory}/Pictures/Wallpapers/${videoName}";
  settings = import ../../../config/dms/settings.nix { configHome = config.xdg.configHome; };
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
    systemd.target = "graphical-session.target";
    enableDynamicTheming = true;
    enableSystemMonitoring = true;
    # GUI state must stay writable. The official settings/session options create store symlinks.
    managePluginSettings = false;
    plugins = {
      catWidget.src = inputs.cat-widget;
      mpvpaper.src = inputs.mpvpaper-plugin;
    };
  };
  home.packages = [
    pkgs.mpvpaper
    pkgs.ffmpeg
  ];
  home.file."Pictures/Wallpapers/${videoName}".source = ../../../collection + "/${videoName}";
  kaenix.seedFiles = [
    {
      target = ".config/DankMaterialShell/settings.json";
      source = json "dms-settings.json" settings;
    }
    {
      target = ".config/DankMaterialShell/plugin_settings.json";
      source = json "dms-plugins.json" pluginSettings;
    }
    {
      target = ".local/state/DankMaterialShell/session.json";
      source = json "dms-session.json" { showThirdPartyPlugins = true; };
    }
    {
      target = ".config/DankMaterialShell/themes/catppuccin/theme.json";
      source = ../../../config/dms/catppuccin.json;
    }
  ];
}
