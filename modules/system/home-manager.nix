{ ... }:
{
  flake.modules.nixos.home-manager = { globals, inputs, ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.extraSpecialArgs = { inherit globals inputs; };
    home-manager.backupFileExtension = "pre-kaenix";
    home-manager.overwriteBackup = false;
    home-manager.sharedModules = [ inputs.dms.homeModules.dank-material-shell ];
  };
}
