{ ... }:
{
  flake.modules.nixos.users =
    { globals, ... }:
    {
      users.users.${globals.username} = {
        isNormalUser = true;
        description = globals.username;
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
      };
    };
}
