{ config, ... }:
{
  flake.modules.nixos.applications = {
    imports = [
      config.flake.modules.nixos.brave
      config.flake.modules.nixos.mpv
    ];
  };
}
