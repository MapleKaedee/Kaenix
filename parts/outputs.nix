{ self, globals, ... }:
{
  flake = {
    packages.x86_64-linux.default =
      self.nixosConfigurations.${globals.hostname}.config.system.build.toplevel;
    packages.x86_64-linux.kae = import ../lib/kae.nix {
      pkgs = self.nixosConfigurations.${globals.hostname}.pkgs;
      hostname = globals.hostname;
      repository = "/home/${globals.username}/Kaenix";
    };
    formatter.x86_64-linux = self.nixosConfigurations.${globals.hostname}.pkgs.nixfmt-tree;
    checks.x86_64-linux = import ../tests/checks.nix {
      pkgs = self.nixosConfigurations.${globals.hostname}.pkgs;
      homeConfig =
        self.nixosConfigurations.${globals.hostname}.config.home-manager.users.${globals.username};
    };
  };
}
