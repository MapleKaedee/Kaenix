{
  config,
  globals,
  inputs,
  ...
}:
let
  features = config.flake.modules.nixos;
in
{
  flake.nixosConfigurations.${globals.hostname} = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit globals inputs; };
    modules = [
      ../../configuration.nix
      features.packages
      # Desktop.
      features.niri
      features.dms
      features.theme
      # Shell.
      features.default-shell
      features.fish
      features.nushell
      features.common
      features.fastfetch
      features.git
      # Apps.
      features.alacritty
      features.brave
      features.btop
      features.helix
      features.mpv
      features.steam
      features.yazi
      # Hardware.
      features.nvidia
      features.asus
      features.power
      features.tablet
      features.bluetooth
      # Services.
      features.audio
      features.printing
      features.automount
      features.session
      features.scx
      # System.
      features.base
      features.users
      features.nix
      features.home-manager
      inputs.chaotic.nixosModules.default
      inputs.home-manager.nixosModules.home-manager
      ({ globals, ... }: {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit globals inputs; };
        home-manager.backupFileExtension = "pre-kaenix";
        home-manager.overwriteBackup = false;
        home-manager.sharedModules = [ inputs.dms.homeModules.dank-material-shell ];
        home-manager.users.${globals.username} = import ../../home.nix;
      })
      # Preserve Kitty's merge position from the pilot, including seed order.
      features.kitty
    ];
  };
}
