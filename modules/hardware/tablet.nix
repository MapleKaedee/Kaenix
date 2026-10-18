{ globals, ... }:
{
  hardware.opentabletdriver.enable = true;
  home-manager.users.${globals.username} =
    { ... }:
    {
      kaenix.seedFiles = [
        {
          target = ".config/OpenTabletDriver/settings.json";
          source = ../../config/opentabletdriver/settings.json;
        }
      ];
    };
}
