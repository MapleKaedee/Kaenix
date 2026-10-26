{ ... }:
{
  flake.modules.nixos.home-manager =
    {
      globals,
      inputs,
      pkgs,
      ...
    }:
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit globals inputs; };
      # Rotate earlier backups instead of blocking activation or overwriting them.
      home-manager.backupCommand = pkgs.writeShellScript "kaenix-home-manager-backup" ''
        exec ${pkgs.coreutils}/bin/mv --backup=numbered --no-target-directory -- "$1" "$1.pre-kaenix"
      '';
      home-manager.sharedModules = [ inputs.dms.homeModules.dank-material-shell ];
    };
}
