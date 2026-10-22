{ lib, ... }:
{
  options.kaenix.users = lib.mkOption {
    internal = true;
    default = { };
    description = "Named user preferences selected explicitly by a host.";
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          username = lib.mkOption { type = lib.types.str; };
          defaultShell = lib.mkOption {
            type = lib.types.enum [
              "nushell"
              "fish"
            ];
          };
          defaultTerminal = lib.mkOption {
            type = lib.types.enum [
              "alacritty"
              "kitty"
            ];
          };
        };
      }
    );
  };

  config.flake.modules.nixos.users =
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
