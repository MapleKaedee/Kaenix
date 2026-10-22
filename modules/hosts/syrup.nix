{
  config,
  inputs,
  ...
}:
let
  globals = config.kaenix.users.kaede // {
    hostname = "syrup";
    installation = import ../../installation/installation.nix;
  };
  features = config.flake.modules.nixos;
in
{
  _module.args = { inherit globals; };

  flake.nixosConfigurations.${globals.hostname} = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit globals inputs; };
    modules = [
      ../../installation/hardware-configuration.nix
      ({ globals, ... }: {
        assertions = [
          {
            assertion = globals.installation.hardwareReady;
            message = "kaenix: replace installation/hardware-configuration.nix and fill installation/installation.nix from the clean install before setting hardwareReady = true.";
          }
        ];
        networking.hostName = globals.hostname;
        system.stateVersion = globals.installation.systemStateVersion;
      })
      features.boot
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
      features.networking
      features.base
      features.users
      features.nix
      features.seed-files
      inputs.chaotic.nixosModules.default
      features.home-manager
      features.home
      # Preserve Kitty's merge position from the pilot, including seed order.
      features.kitty
    ];
  };
}
