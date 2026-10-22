{
  description = "Nyaaaaannnnnnnn";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    import-tree.url = "github:denful/import-tree";

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
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.flake-parts.flakeModules.modules
        (inputs.import-tree ./modules)
      ];
      systems = [ "x86_64-linux" ];
    };
}
