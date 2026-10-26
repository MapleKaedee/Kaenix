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
        limine = globals.installation.bootLoader.limine // {
          maxGenerations = 5;
          extraConfig = builtins.readFile "${inputs.limine-theme}/themes/mocha/catppuccin-mocha-mauve.conf";
        };
      };

      boot.plymouth = {
        enable = true;
        theme = "MikuPlymouth";
        themePackages = [ pkgs.mikuPlymouth ];
      };
    };
}
