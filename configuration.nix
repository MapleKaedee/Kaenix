# NixOS system configuration entrypoint
{ pkgs, globals, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ./modules/env/peripherals.nix
    ./modules/env/users.nix
    ./modules/env/niri.nix
    ./modules/env/dms.nix
    ./modules/env/packages.nix
    ./modules/env/nvidia.nix
  ];

  boot.loader = globals.installation.bootLoader;
  assertions = [{
    assertion = globals.installation.hardwareReady;
    message = "kaenix: replace hardware-configuration.nix and fill installation.nix from the clean install before setting hardwareReady = true.";
  }];

  boot.kernelPackages = pkgs.linuxPackages_cachyos;

  networking.hostName = globals.hostname;

  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Jakarta";

  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  environment.sessionVariables = {
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "30";
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.settings.auto-optimise-store = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono pkgs.jetbrains-mono ];
  fonts.fontconfig.defaultFonts.monospace = [ "JetBrainsMono Nerd Font Mono" ];

  system.stateVersion = globals.installation.systemStateVersion;
}
