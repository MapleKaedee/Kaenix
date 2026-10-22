# NixOS host settings and generated hardware; features are selected in parts/hosts/syrup.nix.
{ globals, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader = globals.installation.bootLoader;
  assertions = [
    {
      assertion = globals.installation.hardwareReady;
      message = "kaenix: replace hardware-configuration.nix and fill installation.nix from the clean install before setting hardwareReady = true.";
    }
  ];

  networking.hostName = globals.hostname;
  system.stateVersion = globals.installation.systemStateVersion;
}
