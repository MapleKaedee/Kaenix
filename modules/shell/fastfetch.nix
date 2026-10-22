{ ... }:
{
  flake.modules.nixos.fastfetch =
    { globals, ... }:
    {
      home-manager.users.${globals.username} =
        { ... }:
        {
          programs.fastfetch = {
            enable = true;
            settings = builtins.fromJSON (builtins.readFile ../../config/fastfetch/settings.json);
          };
          xdg.configFile."fastfetch/hakufetch.txt".source = ../../config/fastfetch/hakufetch.txt;
        };
    };
}
