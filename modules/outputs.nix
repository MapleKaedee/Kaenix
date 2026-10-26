{
  self,
  globals,
  inputs,
  ...
}:
{
  flake = {
    packages.x86_64-linux.default =
      self.nixosConfigurations.${globals.hostname}.config.system.build.toplevel;
    packages.x86_64-linux.kae = import ../lib/kae.nix {
      pkgs = self.nixosConfigurations.${globals.hostname}.pkgs;
      hostname = globals.hostname;
      repository = "/home/${globals.username}/Kaenix";
    };
    packages.x86_64-linux.dsh-desktop =
      self.nixosConfigurations.${globals.hostname}.pkgs.callPackage ../lib/dsh-desktop.nix
        { };
    formatter.x86_64-linux = self.nixosConfigurations.${globals.hostname}.pkgs.nixfmt-tree;
    checks.x86_64-linux =
      let
        pkgs = self.nixosConfigurations.${globals.hostname}.pkgs;
        homeConfig =
          self.nixosConfigurations.${globals.hostname}.config.home-manager.users.${globals.username};
      in
      (import ../tests/checks.nix { inherit pkgs homeConfig; })
      // {
        mpv-config = inputs.mpv-configs.lib.mpvConfigCheck { inherit pkgs homeConfig; };
      };
  };
}
