{ config, ... }:
{
  flake.modules.nixos.workstation = {
    imports = [
      config.flake.modules.nixos.niri
      config.flake.modules.nixos.dms
      config.flake.modules.nixos.theme
      config.flake.modules.nixos.audio
      config.flake.modules.nixos.session
      config.flake.modules.nixos.printing
      config.flake.modules.nixos.automount
    ];
  };
}
