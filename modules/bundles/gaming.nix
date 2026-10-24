{ config, ... }:
{
  flake.modules.nixos.gaming = {
    imports = [
      config.flake.modules.nixos.steam
      config.flake.modules.nixos.osu
    ];
  };
}
