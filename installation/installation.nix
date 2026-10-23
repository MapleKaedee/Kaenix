# Installation settings for syrup; review alongside hardware-configuration.nix
# when adapting to another installation. Preserve the initial state versions.
{
  hardwareReady = true;
  systemStateVersion = "26.11";
  homeStateVersion = "26.11";

  # Keep bootloader settings from the target installation here.
  # They are not contained in hardware-configuration.nix.
  bootLoader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
}
