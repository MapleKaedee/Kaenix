{ globals, ... }:
{
  home-manager.users.${globals.username} =
    { lib, pkgs, ... }:
    let
      assets = ../../config/mpv;
      files = [
        "mpv.conf"
        "input.conf"
        "profiles.conf"
        "script-opts/uosc.conf"
        "script-opts/uosc_lang.conf"
        "script-opts/uosc_addones.conf"
        "script-opts/save_global_props.conf"
      ];
      videoTypes = [
        "video/mp4"
        "video/x-matroska"
        "video/webm"
        "video/quicktime"
        "video/x-msvideo"
        "video/mpeg"
        "video/mp2t"
        "video/ogg"
        "video/x-flv"
        "video/x-ms-wmv"
      ];
    in
    {
      programs.mpv.enable = true;
      xdg.configFile =
        lib.genAttrs (map (name: "mpv/${name}") files) (name: {
          source = assets + "/${lib.removePrefix "mpv/" name}";
        })
        // lib.genAttrs [ "mpv/scripts" "mpv/shaders" "mpv/fonts" ] (name: {
          source = assets + "/${lib.removePrefix "mpv/" name}";
          recursive = true;
        })
        // {
          "mpv/script-opts/thumb_engine.conf".text =
            lib.replaceStrings [ "@FFMPEG@" ] [ (lib.getExe pkgs.ffmpeg) ]
              (builtins.readFile (assets + "/script-opts/thumb_engine.conf"));
        };
      xdg.mimeApps = {
        enable = true;
        defaultApplications = lib.genAttrs videoTypes (_: [ "mpv.desktop" ]);
      };
    };
}
