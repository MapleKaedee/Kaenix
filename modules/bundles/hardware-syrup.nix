{ config, ... }:
{
  flake.modules.nixos.hardware-syrup = {
    imports = [
      config.flake.modules.nixos.nvidia
      config.flake.modules.nixos.asus
      config.flake.modules.nixos.power
      config.flake.modules.nixos.tablet
      config.flake.modules.nixos.bluetooth
      config.flake.modules.nixos.scx
    ];
  };
}
