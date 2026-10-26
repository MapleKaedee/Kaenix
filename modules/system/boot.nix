{ ... }:
{
  flake.modules.nixos.boot =
    {
      globals,
      inputs,
      pkgs,
      ...
    }:
    {
      imports = [ inputs.miku-plymouth.nixosModules.default ];

      boot.kernelPackages = pkgs.linuxPackages_cachyos;
      boot.consoleLogLevel = 3;
      boot.kernelParams = [
        "quiet"
        "udev.log_priority=3"
        "rd.systemd.show_status=auto"
      ];
      boot.loader = globals.installation.bootLoader // {
        grub = globals.installation.bootLoader.grub // {
          theme = "${inputs.grub-theme}/src/catppuccin-mocha-grub-theme";
        };
      };

      boot.plymouth = {
        enable = true;
        theme = "MikuPlymouth";
        themePackages = [ pkgs.mikuPlymouth ];
      };
    };
}
