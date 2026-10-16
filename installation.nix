# Fill these values from the clean installation before deploying this flake.
# hardware-configuration.nix in this checkout still belongs to the OLD install.
{
  hardwareReady = false;
  systemStateVersion = "26.05";
  homeStateVersion = "26.05";

  # Copy boot.loader settings from the installer's configuration.nix here.
  # They are NOT contained in hardware-configuration.nix.
  bootLoader = { };
}
