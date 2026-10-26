# Installation settings for syrup; review alongside hardware-configuration.nix
# when adapting to another installation. Preserve the initial state versions.
{
  hardwareReady = true;
  systemStateVersion = "26.11";
  homeStateVersion = "26.11";

  # Bootloader settings for syrup; these are not in hardware-configuration.nix.
  bootLoader = {
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
    };
    efi.canTouchEfiVariables = true;
  };
}
