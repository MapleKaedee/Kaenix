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
      features.core
      features.packages
      features.workstation
      features.terminal
      features.applications
      features.gaming
      features.hardware-syrup
      inputs.chaotic.nixosModules.default
    ];
  };
}
