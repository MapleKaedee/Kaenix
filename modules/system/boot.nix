{ ... }:
{
  flake.modules.nixos.boot = { pkgs, globals, ... }: {
    boot.kernelPackages = pkgs.linuxPackages_cachyos;
    boot.loader = globals.installation.bootLoader;
  };
}
