{
  description = "Nyaaaaannnnnnnn";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    dms.url = "github:AvengeMedia/DankMaterialShell/stable";
    dms.inputs.nixpkgs.follows = "nixpkgs";

    cat-widget = {
      url = "github:xi-ve/cat-dms/eb7b5138b672be3c06445dd80de6bc30c3076030";
      flake = false;
    };
    mpvpaper-plugin = {
      url = "github:tokisak1kurum1/mpvpaper-plugin/c720365423a4988af4a5d03c967fcac3912d1cb6";
      flake = false;
    };

    chaotic.url = "github:chaotic-cx/nyx";
    chaotic.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    extra-substituters = [ "https://nyx-cache.chaotic.cx/" ];
    extra-trusted-public-keys = [ "nyx-cache.chaotic.cx:dJxTrgMC3V3cFfyIiBQDQorG6k1LsqurH/srpMSq7qk=" ];
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      dms,
      chaotic,
      ...
    }:
    let
      globals = {
        username = "kaede";
        hostname = "syrup";
        # Choose "nushell" or "fish" for login and both terminals.
        defaultShell = "nushell";
        # Choose "alacritty" or "kitty" for desktop terminal launchers.
        defaultTerminal = "kitty";
        installation = import ./installation.nix;
      };
    in
    {
      formatter.x86_64-linux = self.nixosConfigurations.${globals.hostname}.pkgs.nixfmt-tree;
      checks.x86_64-linux = import ./tests/checks.nix {
        pkgs = self.nixosConfigurations.${globals.hostname}.pkgs;
        homeConfig =
          self.nixosConfigurations.${globals.hostname}.config.home-manager.users.${globals.username};
      };
      nixosConfigurations.${globals.hostname} = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit globals inputs; };
        modules = [
          ./configuration.nix
          chaotic.nixosModules.default
          home-manager.nixosModules.home-manager
          ({ globals, ... }: {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit globals inputs; };
            home-manager.backupFileExtension = "pre-kaenix";
            home-manager.overwriteBackup = false;
            home-manager.sharedModules = [ dms.homeModules.dank-material-shell ];
            home-manager.users.${globals.username} = import ./home.nix;
          })
        ];
      };
    };
}
