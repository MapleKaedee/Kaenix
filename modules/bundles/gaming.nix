{ config, ... }:
{
  flake.modules.nixos.gaming = {
    imports = [
      config.flake.modules.nixos.steam
    ];
  };
}
