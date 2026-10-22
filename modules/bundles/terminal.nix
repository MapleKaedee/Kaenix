{ config, ... }:
{
  flake.modules.nixos.terminal = {
    imports = [
      config.flake.modules.nixos.default-shell
      config.flake.modules.nixos.fish
      config.flake.modules.nixos.nushell
      config.flake.modules.nixos.common
      config.flake.modules.nixos.fastfetch
      config.flake.modules.nixos.git
      config.flake.modules.nixos.alacritty
      config.flake.modules.nixos.kitty
      config.flake.modules.nixos.btop
      config.flake.modules.nixos.helix
      config.flake.modules.nixos.yazi
    ];
  };
}
