{ config, ... }:
{
  flake.modules.nixos.core = {
    imports = [
      config.flake.modules.nixos.boot
      config.flake.modules.nixos.networking
      config.flake.modules.nixos.base
      config.flake.modules.nixos.users
      config.flake.modules.nixos.nix
      config.flake.modules.nixos.seed-files
      config.flake.modules.nixos.home-manager
      config.flake.modules.nixos.home
    ];
  };
}
