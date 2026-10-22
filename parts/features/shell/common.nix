{ ... }:
{
  flake.modules.nixos.common =
    { globals, ... }:
    {
      home-manager.users.${globals.username} =
        { ... }:
        {
          programs.starship = {
            enable = true;
            enableFishIntegration = true;
            enableNushellIntegration = true;
            settings = builtins.fromTOML (builtins.readFile ../../../config/starship.toml);
          };
          programs.eza = {
            enable = true;
            enableFishIntegration = false;
            enableNushellIntegration = false;
          };
        };
    };
}
