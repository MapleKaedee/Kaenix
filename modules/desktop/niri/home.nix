# Static base in the store; DMS owns the writable fragments under niri/dms.
{ lib, ... }:
{
  xdg.configFile."niri/config.kdl".text = builtins.readFile ../../../config/niri/config.kdl;
  kaenix.seedFiles = map (name: {
    target = ".config/niri/dms/${name}";
    source = ../../../config/niri/dms + "/${name}";
  }) (lib.attrNames (builtins.readDir ../../../config/niri/dms));
}
