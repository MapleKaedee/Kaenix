{ ... }:
{
  flake.modules.nixos.osu =
    { globals, ... }:
    {
      home-manager.users.${globals.username} =
        { lib, pkgs, ... }:
        let
          osu = pkgs.osu-lazer-bin;
          lowLatency = pkgs.writeShellApplication {
            name = "osu-lowlatency";
            text = ''
              export PIPEWIRE_QUANTUM=128/48000
              exec ${lib.escapeShellArg (lib.getExe osu)} "$@"
            '';
          };
        in
        {
          home.packages = [
            osu
            lowLatency
          ];

          xdg.desktopEntries.osu-lowlatency = {
            name = "osu! — Low Latency";
            comment = "Play osu! with a 128-sample PipeWire quantum at 48 kHz";
            exec = "${lib.getExe lowLatency} %u";
            icon = "osu";
            terminal = false;
            categories = [ "Game" ];
            startupNotify = true;
            settings = {
              StartupWMClass = "osu!";
              SingleMainWindow = "true";
            };
          };
        };
    };
}
