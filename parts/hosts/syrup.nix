{
  config,
  globals,
  inputs,
  ...
}:
{
  flake.nixosConfigurations.${globals.hostname} = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit globals inputs; };
    modules = [
      ../../configuration.nix
      inputs.chaotic.nixosModules.default
      inputs.home-manager.nixosModules.home-manager
      ({ globals, ... }: {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit globals inputs; };
        home-manager.backupFileExtension = "pre-kaenix";
        home-manager.overwriteBackup = false;
        home-manager.sharedModules = [ inputs.dms.homeModules.dank-material-shell ];
        home-manager.users.${globals.username} = import ../../home.nix;
      })
      config.flake.modules.nixos.kitty
    ];
  };
}
